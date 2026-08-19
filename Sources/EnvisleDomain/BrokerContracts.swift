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

    func observeAppliedPolicy(
        for environmentID: EnvironmentID
    ) async throws -> AppliedSharePolicyEvidence
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

public struct NetworkPolicyApplicationReceipt: Codable, Equatable, Sendable {
    public let environmentID: EnvironmentID
    public let acceptedVersion: PolicyVersion

    public init(environmentID: EnvironmentID, acceptedVersion: PolicyVersion) {
        self.environmentID = environmentID
        self.acceptedVersion = acceptedVersion
    }

    private enum CodingKeys: String, CodingKey {
        case environmentID = "environment_id"
        case acceptedVersion = "accepted_version"
    }
}

public enum GuestPolicyProtocol {
    public static let currentVersion: UInt16 = 1
}

public enum GuestPolicyRequestValidationFailure: Error, Equatable, Sendable {
    case unsupportedProtocolVersion(UInt16)
    case requestIDMissing
    case environmentIDMissing
}

public struct GuestPolicyApplyRequest: Codable, Equatable, Sendable {
    public let protocolVersion: UInt16
    public let requestID: String
    public let desiredPolicy: DesiredNetworkPolicy

    public init(
        protocolVersion: UInt16 = GuestPolicyProtocol.currentVersion,
        requestID: String,
        desiredPolicy: DesiredNetworkPolicy
    ) {
        self.protocolVersion = protocolVersion
        self.requestID = requestID
        self.desiredPolicy = desiredPolicy
    }

    private enum CodingKeys: String, CodingKey {
        case protocolVersion = "protocol_version"
        case requestID = "request_id"
        case desiredPolicy = "desired_policy"
    }

    public func validate() throws {
        guard protocolVersion == GuestPolicyProtocol.currentVersion else {
            throw GuestPolicyRequestValidationFailure.unsupportedProtocolVersion(protocolVersion)
        }
        guard !requestID.isEmpty else {
            throw GuestPolicyRequestValidationFailure.requestIDMissing
        }
        try desiredPolicy.validate()
    }
}

public struct GuestPolicyObserveRequest: Codable, Equatable, Sendable {
    public let protocolVersion: UInt16
    public let requestID: String
    public let environmentID: EnvironmentID

    public init(
        protocolVersion: UInt16 = GuestPolicyProtocol.currentVersion,
        requestID: String,
        environmentID: EnvironmentID
    ) {
        self.protocolVersion = protocolVersion
        self.requestID = requestID
        self.environmentID = environmentID
    }

    private enum CodingKeys: String, CodingKey {
        case protocolVersion = "protocol_version"
        case requestID = "request_id"
        case environmentID = "environment_id"
    }

    public func validate() throws {
        guard protocolVersion == GuestPolicyProtocol.currentVersion else {
            throw GuestPolicyRequestValidationFailure.unsupportedProtocolVersion(protocolVersion)
        }
        guard !requestID.isEmpty else {
            throw GuestPolicyRequestValidationFailure.requestIDMissing
        }
        guard !environmentID.rawValue.isEmpty else {
            throw GuestPolicyRequestValidationFailure.environmentIDMissing
        }
    }
}

public struct GuestPolicyApplyResponse: Codable, Equatable, Sendable {
    public let protocolVersion: UInt16
    public let requestID: String
    public let receipt: NetworkPolicyApplicationReceipt

    public init(
        protocolVersion: UInt16 = GuestPolicyProtocol.currentVersion,
        requestID: String,
        receipt: NetworkPolicyApplicationReceipt
    ) {
        self.protocolVersion = protocolVersion
        self.requestID = requestID
        self.receipt = receipt
    }

    private enum CodingKeys: String, CodingKey {
        case protocolVersion = "protocol_version"
        case requestID = "request_id"
        case receipt
    }
}

public struct GuestPolicyObserveResponse: Codable, Equatable, Sendable {
    public let protocolVersion: UInt16
    public let requestID: String
    public let evidence: AppliedNetworkPolicyEvidence

    public init(
        protocolVersion: UInt16 = GuestPolicyProtocol.currentVersion,
        requestID: String,
        evidence: AppliedNetworkPolicyEvidence
    ) {
        self.protocolVersion = protocolVersion
        self.requestID = requestID
        self.evidence = evidence
    }

    private enum CodingKeys: String, CodingKey {
        case protocolVersion = "protocol_version"
        case requestID = "request_id"
        case evidence
    }
}

public enum QuarantineDisposition: String, Codable, Equatable, Sendable {
    case networkIsolationConfirmed = "network_isolation_confirmed"
    case runtimeStopRequired = "runtime_stop_required"
}

public protocol NetworkBroker: Sendable {
    func apply(
        _ desiredPolicy: DesiredEnvironmentPolicy
    ) async throws -> NetworkPolicyApplicationReceipt
    func observeAppliedPolicy(
        for environmentID: EnvironmentID
    ) async throws -> AppliedNetworkPolicyEvidence
    func quarantine(
        _ environmentID: EnvironmentID,
        reason: QuarantineReason
    ) async throws -> QuarantineDisposition
}

public protocol GuestPolicyTransport: Sendable {
    func apply(_ request: GuestPolicyApplyRequest) async throws -> GuestPolicyApplyResponse
    func observe(_ request: GuestPolicyObserveRequest) async throws -> GuestPolicyObserveResponse
}
