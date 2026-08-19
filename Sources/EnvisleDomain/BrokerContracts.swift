public struct SystemDiskRequest: Codable, Equatable, Sendable {
    public let environmentID: EnvironmentID
    public let capacityBytes: UInt64

    public init(environmentID: EnvironmentID, capacityBytes: UInt64) {
        self.environmentID = environmentID
        self.capacityBytes = capacityBytes
    }
}

public struct SystemDiskAttachment: Codable, Equatable, Sendable {
    public let environmentID: EnvironmentID
    public let storageResourceID: String

    public init(environmentID: EnvironmentID, storageResourceID: String) {
        self.environmentID = environmentID
        self.storageResourceID = storageResourceID
    }
}

public protocol StorageBroker: Sendable {
    func allocateSystemDisk(_ request: SystemDiskRequest) async throws -> SystemDiskAttachment
    func releaseSystemDisk(_ attachment: SystemDiskAttachment) async throws
}

public protocol ShareBroker: Sendable {
    func authorize(
        _ share: ShareAuthorization,
        for environmentID: EnvironmentID
    ) async throws -> ShareChangeDisposition

    func revoke(
        authorizationID: AuthorizationID,
        from environmentID: EnvironmentID
    ) async throws -> ShareChangeDisposition
}

public enum ShareChangeDisposition: String, Codable, Equatable, Sendable {
    case applied
    case runtimeRestartRequired = "runtime_restart_required"
}

public enum QuarantineReason: String, Codable, Equatable, Sendable {
    case guestAgentUnreachable = "guest_agent_unreachable"
    case policyApplicationFailed = "policy_application_failed"
    case policyEvidenceMismatch = "policy_evidence_mismatch"
}

public struct PolicyApplicationReceipt: Codable, Equatable, Sendable {
    public let environmentID: EnvironmentID
    public let acceptedVersion: PolicyVersion

    public init(environmentID: EnvironmentID, acceptedVersion: PolicyVersion) {
        self.environmentID = environmentID
        self.acceptedVersion = acceptedVersion
    }
}

public enum QuarantineDisposition: String, Codable, Equatable, Sendable {
    case networkIsolationConfirmed = "network_isolation_confirmed"
    case runtimeStopRequired = "runtime_stop_required"
}

public protocol NetworkBroker: Sendable {
    func apply(_ desiredPolicy: DesiredEnvironmentPolicy) async throws -> PolicyApplicationReceipt
    func observeAppliedPolicy(for environmentID: EnvironmentID) async throws -> AppliedPolicyEvidence
    func quarantine(
        _ environmentID: EnvironmentID,
        reason: QuarantineReason
    ) async throws -> QuarantineDisposition
}

public protocol GuestPolicyTransport: Sendable {
    func apply(_ desiredPolicy: DesiredEnvironmentPolicy) async throws -> PolicyApplicationReceipt
    func observe(for environmentID: EnvironmentID) async throws -> AppliedPolicyEvidence
}
