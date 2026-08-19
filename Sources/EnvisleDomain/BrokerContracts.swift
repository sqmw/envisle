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
        for environmentID: EnvironmentID,
        runtimeInstanceID: RuntimeInstanceID
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
    public let runtimeInstanceID: RuntimeInstanceID
    public let acceptedVersion: PolicyVersion

    public init(
        environmentID: EnvironmentID,
        runtimeInstanceID: RuntimeInstanceID,
        acceptedVersion: PolicyVersion
    ) {
        self.environmentID = environmentID
        self.runtimeInstanceID = runtimeInstanceID
        self.acceptedVersion = acceptedVersion
    }

    private enum CodingKeys: String, CodingKey {
        case environmentID = "environment_id"
        case runtimeInstanceID = "runtime_instance_id"
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
    case runtimeInstanceIDMissing
}

public enum GuestPolicyResponseValidationFailure: Error, Equatable, Sendable {
    case unsupportedProtocolVersion(UInt16)
    case requestIDMismatch
    case environmentIDMismatch
    case runtimeInstanceIDMismatch
    case policyVersionMismatch
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
    public let runtimeInstanceID: RuntimeInstanceID

    public init(
        protocolVersion: UInt16 = GuestPolicyProtocol.currentVersion,
        requestID: String,
        environmentID: EnvironmentID,
        runtimeInstanceID: RuntimeInstanceID
    ) {
        self.protocolVersion = protocolVersion
        self.requestID = requestID
        self.environmentID = environmentID
        self.runtimeInstanceID = runtimeInstanceID
    }

    private enum CodingKeys: String, CodingKey {
        case protocolVersion = "protocol_version"
        case requestID = "request_id"
        case environmentID = "environment_id"
        case runtimeInstanceID = "runtime_instance_id"
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
        guard !runtimeInstanceID.rawValue.isEmpty else {
            throw GuestPolicyRequestValidationFailure.runtimeInstanceIDMissing
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

    public func validate(matching request: GuestPolicyApplyRequest) throws {
        try request.validate()
        guard protocolVersion == GuestPolicyProtocol.currentVersion,
              protocolVersion == request.protocolVersion else {
            throw GuestPolicyResponseValidationFailure.unsupportedProtocolVersion(protocolVersion)
        }
        guard requestID == request.requestID else {
            throw GuestPolicyResponseValidationFailure.requestIDMismatch
        }
        guard receipt.environmentID == request.desiredPolicy.environmentID else {
            throw GuestPolicyResponseValidationFailure.environmentIDMismatch
        }
        guard receipt.runtimeInstanceID == request.desiredPolicy.runtimeInstanceID else {
            throw GuestPolicyResponseValidationFailure.runtimeInstanceIDMismatch
        }
        guard receipt.acceptedVersion == request.desiredPolicy.version else {
            throw GuestPolicyResponseValidationFailure.policyVersionMismatch
        }
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

    public func validate(matching request: GuestPolicyObserveRequest) throws {
        try request.validate()
        guard protocolVersion == GuestPolicyProtocol.currentVersion,
              protocolVersion == request.protocolVersion else {
            throw GuestPolicyResponseValidationFailure.unsupportedProtocolVersion(protocolVersion)
        }
        guard requestID == request.requestID else {
            throw GuestPolicyResponseValidationFailure.requestIDMismatch
        }
        guard evidence.environmentID == request.environmentID else {
            throw GuestPolicyResponseValidationFailure.environmentIDMismatch
        }
        guard evidence.runtimeInstanceID == request.runtimeInstanceID else {
            throw GuestPolicyResponseValidationFailure.runtimeInstanceIDMismatch
        }
    }
}

public enum QuarantineDisposition: String, Codable, Equatable, Sendable {
    case networkIsolationConfirmed = "network_isolation_confirmed"
    case runtimeStopRequired = "runtime_stop_required"
}

public protocol NetworkBroker: Sendable {
    func apply(
        _ desiredPolicy: DesiredEnvironmentPolicy,
        runtimeInstanceID: RuntimeInstanceID
    ) async throws -> NetworkPolicyApplicationReceipt
    func observeAppliedPolicy(
        for environmentID: EnvironmentID,
        runtimeInstanceID: RuntimeInstanceID
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
