import XCTest
@testable import EnvisleDomain

final class RuntimeRouterTests: XCTestCase {
    func testSelectsHighestPriorityExactCapableProvider() throws {
        let low = Fixtures.provider(id: "low", priority: 1)
        let high = Fixtures.provider(id: "high", priority: 10)
        let requirement = RuntimeRequirement(
            placement: Fixtures.placement,
            requiredCapabilities: Fixtures.requiredCapabilities
        )

        let decision = try RuntimeRouter.route(
            requirement: requirement,
            providers: [low, high]
        )

        XCTAssertEqual(decision.selectedProvider.id, high.id)
    }

    func testMissingSecurityCapabilityProducesExplainableRejection() {
        let capabilities = Fixtures.requiredCapabilities.subtracting([.appliedNetworkPolicyQuery])
        let provider = Fixtures.provider(id: "incomplete", capabilities: capabilities)
        let requirement = RuntimeRequirement(
            placement: Fixtures.placement,
            requiredCapabilities: Fixtures.requiredCapabilities
        )

        XCTAssertThrowsError(
            try RuntimeRouter.route(requirement: requirement, providers: [provider])
        ) { error in
            let failure = error as? RuntimeRoutingFailure
            XCTAssertEqual(
                failure?.evaluations,
                [
                    ProviderEvaluation(
                        providerID: provider.id,
                        rejection: .missingCapabilities([.appliedNetworkPolicyQuery])
                    ),
                ]
            )
        }
    }

    func testCrossArchitectureProviderIsRejectedWithoutFallback() {
        let x86Placement = EnvironmentPlacement(
            hostOS: .macOS,
            hostArchitecture: .arm64,
            guestOS: .linux,
            guestArchitecture: .x86_64
        )
        let provider = Fixtures.provider(id: "x86", placement: x86Placement)
        let requirement = RuntimeRequirement(
            placement: Fixtures.placement,
            requiredCapabilities: Fixtures.requiredCapabilities
        )

        XCTAssertThrowsError(
            try RuntimeRouter.route(requirement: requirement, providers: [provider])
        ) { error in
            let failure = error as? RuntimeRoutingFailure
            XCTAssertEqual(
                failure?.evaluations.first?.rejection,
                .unsupportedPlacement(Fixtures.placement)
            )
        }
    }
}
