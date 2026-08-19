@testable import EnvisleDomain

enum Fixtures {
    static let environmentID = EnvironmentID(rawValue: "environment-1")
    static let otherEnvironmentID = EnvironmentID(rawValue: "environment-2")

    static let placement = EnvironmentPlacement(
        hostOS: .macOS,
        hostArchitecture: .arm64,
        guestOS: .linux,
        guestArchitecture: .arm64
    )

    static let requiredCapabilities: Set<RuntimeCapability> = [
        .create,
        .start,
        .stop,
        .delete,
        .observe,
        .independentSystemDisk,
        .readOnlyShareAtBoot,
        .guestPolicyAgent,
        .appliedNetworkPolicyQuery,
        .appliedSharePolicyQuery,
        .quarantine,
    ]

    static func policy(
        environmentID: EnvironmentID = environmentID,
        version: PolicyVersion = PolicyVersion(revision: 4, digest: "sha256:policy-4"),
        shares: [ShareAuthorization] = [],
        inboundPorts: [InboundPortAuthorization] = []
    ) -> DesiredEnvironmentPolicy {
        DesiredEnvironmentPolicy(
            environmentID: environmentID,
            version: version,
            lease: PolicyLease(
                renewalIntervalMilliseconds: 5_000,
                failClosedAfterMilliseconds: 15_000
            ),
            shares: shares,
            inboundPorts: inboundPorts
        )
    }

    static func appliedNetwork(
        environmentID: EnvironmentID = environmentID,
        version: PolicyVersion? = PolicyVersion(revision: 4, digest: "sha256:policy-4"),
        status: AppliedPolicyStatus = .enforced,
        health: GuestAgentHealth = .healthy,
        observedAt: UInt64 = 10_000,
        leaseRemaining: UInt64? = 12_000
    ) -> AppliedNetworkPolicyEvidence {
        AppliedNetworkPolicyEvidence(
            environmentID: environmentID,
            version: version,
            status: status,
            agentHealth: health,
            observedAtUnixMilliseconds: observedAt,
            leaseRemainingMilliseconds: leaseRemaining
        )
    }

    static func appliedShares(
        environmentID: EnvironmentID = environmentID,
        version: PolicyVersion? = PolicyVersion(revision: 4, digest: "sha256:policy-4"),
        status: AppliedPolicyStatus = .enforced,
        observedAt: UInt64 = 10_000
    ) -> AppliedSharePolicyEvidence {
        AppliedSharePolicyEvidence(
            environmentID: environmentID,
            version: version,
            status: status,
            observedAtUnixMilliseconds: observedAt
        )
    }

    static func provider(
        id: String,
        priority: Int = 0,
        placement: EnvironmentPlacement = placement,
        capabilities: Set<RuntimeCapability> = requiredCapabilities
    ) -> ProviderDescriptor {
        ProviderDescriptor(
            id: ProviderID(rawValue: id),
            version: "1.0.0",
            priority: priority,
            supportedRuntimes: [SupportedRuntime(placement: placement)],
            capabilities: capabilities
        )
    }
}
