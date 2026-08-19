import XCTest
@testable import EnvisleDomain

final class ReadinessTests: XCTestCase {
    func testReadyRequiresCurrentMatchingEnforcedEvidence() {
        let result = EnvironmentReadinessEvaluator.evaluate(
            lifecycle: .running,
            desiredPolicy: Fixtures.policy(),
            appliedNetworkPolicy: Fixtures.appliedNetwork(),
            appliedSharePolicy: Fixtures.appliedShares(),
            nowUnixMilliseconds: 11_000
        )

        XCTAssertEqual(result, .ready)
    }

    func testRunningWithoutEvidenceIsNotReady() {
        let result = EnvironmentReadinessEvaluator.evaluate(
            lifecycle: .running,
            desiredPolicy: Fixtures.policy(),
            appliedNetworkPolicy: nil,
            appliedSharePolicy: Fixtures.appliedShares(),
            nowUnixMilliseconds: 11_000
        )

        XCTAssertEqual(result, .notReady(.policyEvidenceMissing))
    }

    func testStoppedRuntimeCannotBeReadyWithMatchingPolicy() {
        let result = EnvironmentReadinessEvaluator.evaluate(
            lifecycle: .stopped,
            desiredPolicy: Fixtures.policy(),
            appliedNetworkPolicy: Fixtures.appliedNetwork(),
            appliedSharePolicy: Fixtures.appliedShares(),
            nowUnixMilliseconds: 11_000
        )

        XCTAssertEqual(result, .notReady(.runtimeNotRunning(.stopped)))
    }

    func testUnhealthyAgentAndCrossEnvironmentEvidenceFailClosed() {
        let unhealthy = EnvironmentReadinessEvaluator.evaluate(
            lifecycle: .running,
            desiredPolicy: Fixtures.policy(),
            appliedNetworkPolicy: Fixtures.appliedNetwork(health: .unreachable),
            appliedSharePolicy: Fixtures.appliedShares(),
            nowUnixMilliseconds: 11_000
        )
        XCTAssertEqual(unhealthy, .notReady(.guestAgentNotHealthy(.unreachable)))

        let wrongEnvironment = EnvironmentReadinessEvaluator.evaluate(
            lifecycle: .running,
            desiredPolicy: Fixtures.policy(),
            appliedNetworkPolicy: Fixtures.appliedNetwork(
                environmentID: Fixtures.otherEnvironmentID
            ),
            appliedSharePolicy: Fixtures.appliedShares(),
            nowUnixMilliseconds: 11_000
        )
        XCTAssertEqual(wrongEnvironment, .notReady(.policyEnvironmentMismatch))

        let missingShareEvidence = EnvironmentReadinessEvaluator.evaluate(
            lifecycle: .running,
            desiredPolicy: Fixtures.policy(),
            appliedNetworkPolicy: Fixtures.appliedNetwork(),
            appliedSharePolicy: nil,
            nowUnixMilliseconds: 11_000
        )
        XCTAssertEqual(missingShareEvidence, .notReady(.shareEvidenceMissing))

        let wrongShareRevision = EnvironmentReadinessEvaluator.evaluate(
            lifecycle: .running,
            desiredPolicy: Fixtures.policy(),
            appliedNetworkPolicy: Fixtures.appliedNetwork(),
            appliedSharePolicy: Fixtures.appliedShares(
                version: PolicyVersion(revision: 3, digest: "sha256:policy-3")
            ),
            nowUnixMilliseconds: 11_000
        )
        XCTAssertEqual(
            wrongShareRevision,
            .notReady(.sharePolicyRevisionMismatch(desired: 4, applied: 3))
        )
    }

    func testRevisionDigestAndSchemaMismatchesFailClosed() {
        let revision = EnvironmentReadinessEvaluator.evaluate(
            lifecycle: .running,
            desiredPolicy: Fixtures.policy(),
            appliedNetworkPolicy: Fixtures.appliedNetwork(
                version: PolicyVersion(revision: 3, digest: "sha256:policy-3")
            ),
            appliedSharePolicy: Fixtures.appliedShares(),
            nowUnixMilliseconds: 11_000
        )
        XCTAssertEqual(revision, .notReady(.policyRevisionMismatch(desired: 4, applied: 3)))

        let digest = EnvironmentReadinessEvaluator.evaluate(
            lifecycle: .running,
            desiredPolicy: Fixtures.policy(),
            appliedNetworkPolicy: Fixtures.appliedNetwork(
                version: PolicyVersion(revision: 4, digest: "different")
            ),
            appliedSharePolicy: Fixtures.appliedShares(),
            nowUnixMilliseconds: 11_000
        )
        XCTAssertEqual(digest, .notReady(.policyDigestMismatch))

        let schema = EnvironmentReadinessEvaluator.evaluate(
            lifecycle: .running,
            desiredPolicy: Fixtures.policy(),
            appliedNetworkPolicy: Fixtures.appliedNetwork(
                version: PolicyVersion(schema: 2, revision: 4, digest: "sha256:policy-4")
            ),
            appliedSharePolicy: Fixtures.appliedShares(),
            nowUnixMilliseconds: 11_000
        )
        XCTAssertEqual(schema, .notReady(.policySchemaMismatch(desired: 1, applied: 2)))
    }

    func testStaleOrExpiredLeaseEvidenceFailsClosed() {
        let stale = EnvironmentReadinessEvaluator.evaluate(
            lifecycle: .running,
            desiredPolicy: Fixtures.policy(),
            appliedNetworkPolicy: Fixtures.appliedNetwork(observedAt: 10_000),
            appliedSharePolicy: Fixtures.appliedShares(),
            nowUnixMilliseconds: 16_000
        )
        XCTAssertEqual(stale, .notReady(.policyEvidenceStale))

        let expired = EnvironmentReadinessEvaluator.evaluate(
            lifecycle: .running,
            desiredPolicy: Fixtures.policy(),
            appliedNetworkPolicy: Fixtures.appliedNetwork(
                observedAt: 10_000,
                leaseRemaining: 500
            ),
            appliedSharePolicy: Fixtures.appliedShares(),
            nowUnixMilliseconds: 11_000
        )
        XCTAssertEqual(expired, .notReady(.policyLeaseExpired))

        let future = EnvironmentReadinessEvaluator.evaluate(
            lifecycle: .running,
            desiredPolicy: Fixtures.policy(),
            appliedNetworkPolicy: Fixtures.appliedNetwork(observedAt: 12_000),
            appliedSharePolicy: Fixtures.appliedShares(),
            nowUnixMilliseconds: 11_000
        )
        XCTAssertEqual(future, .notReady(.policyEvidenceFromFuture))
    }
}
