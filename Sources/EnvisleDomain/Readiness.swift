public enum EnvironmentNotReadyReason: Equatable, Sendable {
    case runtimeNotRunning(EnvironmentLifecycleState)
    case policyEvidenceMissing
    case guestAgentNotHealthy(GuestAgentHealth)
    case policyNotEnforced(AppliedPolicyStatus)
    case policyEnvironmentMismatch
    case policySchemaMismatch(desired: UInt16, applied: UInt16)
    case policyRevisionMismatch(desired: UInt64, applied: UInt64)
    case policyDigestMismatch
    case policyEvidenceFromFuture
    case policyEvidenceStale
    case policyLeaseInvalid
    case policyLeaseExpired
    case shareEvidenceMissing
    case sharePolicyEnvironmentMismatch
    case sharePolicyNotEnforced(AppliedPolicyStatus)
    case sharePolicySchemaMismatch(desired: UInt16, applied: UInt16)
    case sharePolicyRevisionMismatch(desired: UInt64, applied: UInt64)
    case sharePolicyDigestMismatch
}

public enum EnvironmentReadiness: Equatable, Sendable {
    case ready
    case notReady(EnvironmentNotReadyReason)
}

public enum EnvironmentReadinessEvaluator {
    public static func evaluate(
        lifecycle: EnvironmentLifecycleState,
        desiredPolicy: DesiredEnvironmentPolicy,
        appliedNetworkPolicy: AppliedNetworkPolicyEvidence?,
        appliedSharePolicy: AppliedSharePolicyEvidence?,
        nowUnixMilliseconds: UInt64
    ) -> EnvironmentReadiness {
        guard lifecycle == .running else {
            return .notReady(.runtimeNotRunning(lifecycle))
        }
        guard let appliedPolicy = appliedNetworkPolicy else {
            return .notReady(.policyEvidenceMissing)
        }
        guard appliedPolicy.agentHealth == .healthy else {
            return .notReady(.guestAgentNotHealthy(appliedPolicy.agentHealth))
        }
        guard appliedPolicy.status == .enforced else {
            return .notReady(.policyNotEnforced(appliedPolicy.status))
        }
        guard appliedPolicy.environmentID == desiredPolicy.environmentID else {
            return .notReady(.policyEnvironmentMismatch)
        }
        guard let appliedVersion = appliedPolicy.version else {
            return .notReady(.policyEvidenceMissing)
        }
        guard desiredPolicy.version.schema == appliedVersion.schema else {
            return .notReady(
                .policySchemaMismatch(
                    desired: desiredPolicy.version.schema,
                    applied: appliedVersion.schema
                )
            )
        }
        guard desiredPolicy.version.revision == appliedVersion.revision else {
            return .notReady(
                .policyRevisionMismatch(
                    desired: desiredPolicy.version.revision,
                    applied: appliedVersion.revision
                )
            )
        }
        guard desiredPolicy.version.digest == appliedVersion.digest else {
            return .notReady(.policyDigestMismatch)
        }
        guard appliedPolicy.observedAtUnixMilliseconds <= nowUnixMilliseconds else {
            return .notReady(.policyEvidenceFromFuture)
        }
        let evidenceAge = nowUnixMilliseconds - appliedPolicy.observedAtUnixMilliseconds
        guard evidenceAge <= desiredPolicy.lease.renewalIntervalMilliseconds else {
            return .notReady(.policyEvidenceStale)
        }
        guard let remaining = appliedPolicy.leaseRemainingMilliseconds,
              remaining <= desiredPolicy.lease.failClosedAfterMilliseconds else {
            return .notReady(.policyLeaseInvalid)
        }
        guard remaining > evidenceAge else {
            return .notReady(.policyLeaseExpired)
        }

        guard let appliedSharePolicy else {
            return .notReady(.shareEvidenceMissing)
        }
        guard appliedSharePolicy.environmentID == desiredPolicy.environmentID else {
            return .notReady(.sharePolicyEnvironmentMismatch)
        }
        guard appliedSharePolicy.status == .enforced else {
            return .notReady(.sharePolicyNotEnforced(appliedSharePolicy.status))
        }
        guard let shareVersion = appliedSharePolicy.version else {
            return .notReady(.shareEvidenceMissing)
        }
        guard desiredPolicy.version.schema == shareVersion.schema else {
            return .notReady(
                .sharePolicySchemaMismatch(
                    desired: desiredPolicy.version.schema,
                    applied: shareVersion.schema
                )
            )
        }
        guard desiredPolicy.version.revision == shareVersion.revision else {
            return .notReady(
                .sharePolicyRevisionMismatch(
                    desired: desiredPolicy.version.revision,
                    applied: shareVersion.revision
                )
            )
        }
        guard desiredPolicy.version.digest == shareVersion.digest else {
            return .notReady(.sharePolicyDigestMismatch)
        }
        return .ready
    }
}
