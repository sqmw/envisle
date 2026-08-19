import XCTest
@testable import EnvisleDomain

final class ReadinessTests: XCTestCase {
    func testReadyRequiresCurrentMatchingNetworkAndShareEvidence() {
        XCTAssertEqual(evaluate(), .ready)
    }

    func testRuntimeAndBothEvidenceSourcesAreMandatory() {
        XCTAssertEqual(evaluate(lifecycle: .stopped), .notReady(.runtimeNotRunning(.stopped)))
        XCTAssertEqual(evaluate(network: nil), .notReady(.policyEvidenceMissing))
        XCTAssertEqual(evaluate(shares: nil), .notReady(.shareEvidenceMissing))
    }

    func testUnhealthyAgentAndCrossEnvironmentEvidenceFailClosed() {
        XCTAssertEqual(
            evaluate(network: Fixtures.appliedNetwork(health: .unreachable)),
            .notReady(.guestAgentNotHealthy(.unreachable))
        )
        XCTAssertEqual(
            evaluate(network: Fixtures.appliedNetwork(environmentID: Fixtures.otherEnvironmentID)),
            .notReady(.policyEnvironmentMismatch)
        )
        XCTAssertEqual(
            evaluate(shares: Fixtures.appliedShares(environmentID: Fixtures.otherEnvironmentID)),
            .notReady(.sharePolicyEnvironmentMismatch)
        )
    }

    func testEvidenceFromPreviousRuntimeInstanceCannotBeReplayed() {
        XCTAssertEqual(
            evaluate(
                network: Fixtures.appliedNetwork(
                    runtimeInstanceID: Fixtures.previousRuntimeInstanceID
                )
            ),
            .notReady(.policyRuntimeInstanceMismatch)
        )
        XCTAssertEqual(
            evaluate(
                shares: Fixtures.appliedShares(
                    runtimeInstanceID: Fixtures.previousRuntimeInstanceID
                )
            ),
            .notReady(.sharePolicyRuntimeInstanceMismatch)
        )
    }

    func testNetworkRevisionDigestAndSchemaMismatchesFailClosed() {
        XCTAssertEqual(
            evaluate(
                network: Fixtures.appliedNetwork(
                    version: PolicyVersion(revision: 3, digest: "sha256:policy-3")
                )
            ),
            .notReady(.policyRevisionMismatch(desired: 4, applied: 3))
        )
        XCTAssertEqual(
            evaluate(
                network: Fixtures.appliedNetwork(
                    version: PolicyVersion(revision: 4, digest: "different")
                )
            ),
            .notReady(.policyDigestMismatch)
        )
        XCTAssertEqual(
            evaluate(
                network: Fixtures.appliedNetwork(
                    version: PolicyVersion(schema: 2, revision: 4, digest: "sha256:policy-4")
                )
            ),
            .notReady(.policySchemaMismatch(desired: 1, applied: 2))
        )
    }

    func testNetworkEvidenceAndLeaseFreshnessFailClosed() {
        XCTAssertEqual(
            evaluate(network: Fixtures.appliedNetwork(observedAt: 10_000), now: 16_000),
            .notReady(.policyEvidenceStale)
        )
        XCTAssertEqual(
            evaluate(
                network: Fixtures.appliedNetwork(observedAt: 10_000, leaseRemaining: 500)
            ),
            .notReady(.policyLeaseExpired)
        )
        XCTAssertEqual(
            evaluate(network: Fixtures.appliedNetwork(observedAt: 12_000)),
            .notReady(.policyEvidenceFromFuture)
        )
    }

    func testShareEvidenceMustBeFreshForCurrentRuntime() {
        XCTAssertEqual(
            evaluate(shares: Fixtures.appliedShares(observedAt: 5_000), now: 11_000),
            .notReady(.shareEvidenceStale)
        )
        XCTAssertEqual(
            evaluate(shares: Fixtures.appliedShares(observedAt: 12_000)),
            .notReady(.shareEvidenceFromFuture)
        )
    }

    func testInvalidDesiredPolicyCannotBecomeReadyWhenEvidenceEchoesIt() {
        let invalid = Fixtures.policy(version: PolicyVersion(revision: 0, digest: ""))

        XCTAssertEqual(
            evaluate(desired: invalid),
            .notReady(.invalidDesiredPolicy(.revisionMustBePositive))
        )
    }

    private func evaluate(
        lifecycle: EnvironmentLifecycleState = .running,
        runtimeInstanceID: RuntimeInstanceID = Fixtures.runtimeInstanceID,
        desired: DesiredEnvironmentPolicy = Fixtures.policy(),
        network: AppliedNetworkPolicyEvidence? = Fixtures.appliedNetwork(),
        shares: AppliedSharePolicyEvidence? = Fixtures.appliedShares(),
        now: UInt64 = 11_000
    ) -> EnvironmentReadiness {
        EnvironmentReadinessEvaluator.evaluate(
            lifecycle: lifecycle,
            runtimeInstanceID: runtimeInstanceID,
            desiredPolicy: desired,
            appliedNetworkPolicy: network,
            appliedSharePolicy: shares,
            nowUnixMilliseconds: now
        )
    }
}
