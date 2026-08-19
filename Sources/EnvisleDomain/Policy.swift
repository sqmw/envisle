public struct PolicyVersion: Codable, Equatable, Hashable, Sendable {
    public static let currentSchema: UInt16 = 1

    public let schema: UInt16
    public let revision: UInt64
    public let digest: String

    public init(schema: UInt16 = Self.currentSchema, revision: UInt64, digest: String) {
        self.schema = schema
        self.revision = revision
        self.digest = digest
    }
}

public enum ShareAccess: String, Codable, Equatable, Sendable {
    case readOnly = "read_only"
}

public struct ShareAuthorization: Codable, Equatable, Sendable {
    public let id: AuthorizationID
    public let hostResourceID: String
    public let guestMountName: String
    public let access: ShareAccess

    public init(
        id: AuthorizationID,
        hostResourceID: String,
        guestMountName: String,
        access: ShareAccess = .readOnly
    ) {
        self.id = id
        self.hostResourceID = hostResourceID
        self.guestMountName = guestMountName
        self.access = access
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case hostResourceID = "host_resource_id"
        case guestMountName = "guest_mount_name"
        case access
    }
}

public enum TransportProtocol: String, Codable, Equatable, Sendable {
    case tcp
    case udp
}

public struct InboundPortAuthorization: Codable, Equatable, Sendable {
    public let id: AuthorizationID
    public let transport: TransportProtocol
    public let guestPort: UInt16

    public init(id: AuthorizationID, transport: TransportProtocol, guestPort: UInt16) {
        self.id = id
        self.transport = transport
        self.guestPort = guestPort
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case transport
        case guestPort = "guest_port"
    }
}

public enum HostInboundPolicy: String, Codable, Equatable, Sendable {
    case denyByDefault = "deny_by_default"
}

public enum GuestPeerPolicy: String, Codable, Equatable, Sendable {
    case deny = "deny"
}

public struct NetworkBaseline: Codable, Equatable, Sendable {
    public let hostInbound: HostInboundPolicy
    public let guestPeers: GuestPeerPolicy

    public init(
        hostInbound: HostInboundPolicy = .denyByDefault,
        guestPeers: GuestPeerPolicy = .deny
    ) {
        self.hostInbound = hostInbound
        self.guestPeers = guestPeers
    }

    private enum CodingKeys: String, CodingKey {
        case hostInbound = "host_inbound"
        case guestPeers = "guest_peers"
    }
}

public struct PolicyLease: Codable, Equatable, Sendable {
    public let renewalIntervalMilliseconds: UInt64
    public let failClosedAfterMilliseconds: UInt64

    public init(
        renewalIntervalMilliseconds: UInt64,
        failClosedAfterMilliseconds: UInt64
    ) {
        self.renewalIntervalMilliseconds = renewalIntervalMilliseconds
        self.failClosedAfterMilliseconds = failClosedAfterMilliseconds
    }

    private enum CodingKeys: String, CodingKey {
        case renewalIntervalMilliseconds = "renewal_interval_milliseconds"
        case failClosedAfterMilliseconds = "fail_closed_after_milliseconds"
    }
}

public enum PolicyValidationFailure: Error, Equatable, Sendable {
    case environmentIDMissing
    case runtimeInstanceIDMissing
    case unsupportedSchema(UInt16)
    case revisionMustBePositive
    case digestMissing
    case invalidLease
    case authorizationIDMissing
    case duplicateAuthorizationID(AuthorizationID)
    case hostResourceIDMissing(AuthorizationID)
    case guestMountNameMissing(AuthorizationID)
    case invalidGuestPort(AuthorizationID)
    case duplicateGuestPort(TransportProtocol, UInt16)
}

public struct DesiredEnvironmentPolicy: Codable, Equatable, Sendable {
    public let environmentID: EnvironmentID
    public let version: PolicyVersion
    public let networkBaseline: NetworkBaseline
    public let lease: PolicyLease
    public let shares: [ShareAuthorization]
    public let inboundPorts: [InboundPortAuthorization]

    public init(
        environmentID: EnvironmentID,
        version: PolicyVersion,
        networkBaseline: NetworkBaseline = NetworkBaseline(),
        lease: PolicyLease,
        shares: [ShareAuthorization] = [],
        inboundPorts: [InboundPortAuthorization] = []
    ) {
        self.environmentID = environmentID
        self.version = version
        self.networkBaseline = networkBaseline
        self.lease = lease
        self.shares = shares
        self.inboundPorts = inboundPorts
    }

    private enum CodingKeys: String, CodingKey {
        case environmentID = "environment_id"
        case version
        case networkBaseline = "network_baseline"
        case lease
        case shares
        case inboundPorts = "inbound_ports"
    }

    public func validate() throws {
        guard !environmentID.rawValue.isEmpty else {
            throw PolicyValidationFailure.environmentIDMissing
        }
        guard version.schema == PolicyVersion.currentSchema else {
            throw PolicyValidationFailure.unsupportedSchema(version.schema)
        }
        guard version.revision > 0 else {
            throw PolicyValidationFailure.revisionMustBePositive
        }
        guard !version.digest.isEmpty else {
            throw PolicyValidationFailure.digestMissing
        }
        guard lease.renewalIntervalMilliseconds > 0,
              lease.failClosedAfterMilliseconds > lease.renewalIntervalMilliseconds else {
            throw PolicyValidationFailure.invalidLease
        }

        var authorizationIDs = Set<AuthorizationID>()
        for share in shares {
            try validateAuthorizationID(share.id, existing: &authorizationIDs)
            guard !share.hostResourceID.isEmpty else {
                throw PolicyValidationFailure.hostResourceIDMissing(share.id)
            }
            guard !share.guestMountName.isEmpty else {
                throw PolicyValidationFailure.guestMountNameMissing(share.id)
            }
        }

        var ports = Set<PortKey>()
        for port in inboundPorts {
            try validateAuthorizationID(port.id, existing: &authorizationIDs)
            guard port.guestPort > 0 else {
                throw PolicyValidationFailure.invalidGuestPort(port.id)
            }
            let key = PortKey(transport: port.transport, guestPort: port.guestPort)
            guard ports.insert(key).inserted else {
                throw PolicyValidationFailure.duplicateGuestPort(port.transport, port.guestPort)
            }
        }
    }

    public func networkProjection(for runtimeInstanceID: RuntimeInstanceID) -> DesiredNetworkPolicy {
        DesiredNetworkPolicy(
            environmentID: environmentID,
            runtimeInstanceID: runtimeInstanceID,
            version: version,
            networkBaseline: networkBaseline,
            lease: lease,
            inboundPorts: inboundPorts
        )
    }

    private func validateAuthorizationID(
        _ id: AuthorizationID,
        existing: inout Set<AuthorizationID>
    ) throws {
        guard !id.rawValue.isEmpty else {
            throw PolicyValidationFailure.authorizationIDMissing
        }
        guard existing.insert(id).inserted else {
            throw PolicyValidationFailure.duplicateAuthorizationID(id)
        }
    }
}

public struct EnvironmentAuthorizations: Equatable, Sendable {
    public private(set) var shares: [ShareAuthorization]
    public private(set) var inboundPorts: [InboundPortAuthorization]

    public init(
        shares: [ShareAuthorization] = [],
        inboundPorts: [InboundPortAuthorization] = []
    ) throws {
        self.shares = []
        self.inboundPorts = []
        for share in shares {
            try authorize(share)
        }
        for port in inboundPorts {
            try authorize(port)
        }
    }

    public mutating func authorize(_ share: ShareAuthorization) throws {
        try ensureAuthorizationIDAvailable(share.id)
        guard !share.hostResourceID.isEmpty else {
            throw PolicyValidationFailure.hostResourceIDMissing(share.id)
        }
        guard !share.guestMountName.isEmpty else {
            throw PolicyValidationFailure.guestMountNameMissing(share.id)
        }
        shares.append(share)
    }

    public mutating func authorize(_ port: InboundPortAuthorization) throws {
        try ensureAuthorizationIDAvailable(port.id)
        guard port.guestPort > 0 else {
            throw PolicyValidationFailure.invalidGuestPort(port.id)
        }
        guard !inboundPorts.contains(where: {
            $0.transport == port.transport && $0.guestPort == port.guestPort
        }) else {
            throw PolicyValidationFailure.duplicateGuestPort(port.transport, port.guestPort)
        }
        inboundPorts.append(port)
    }

    @discardableResult
    public mutating func revoke(_ id: AuthorizationID) -> Bool {
        let originalShareCount = shares.count
        let originalPortCount = inboundPorts.count
        shares.removeAll { $0.id == id }
        inboundPorts.removeAll { $0.id == id }
        return shares.count != originalShareCount || inboundPorts.count != originalPortCount
    }

    private func ensureAuthorizationIDAvailable(_ id: AuthorizationID) throws {
        guard !id.rawValue.isEmpty else {
            throw PolicyValidationFailure.authorizationIDMissing
        }
        guard !shares.contains(where: { $0.id == id }),
              !inboundPorts.contains(where: { $0.id == id }) else {
            throw PolicyValidationFailure.duplicateAuthorizationID(id)
        }
    }
}

private struct PortKey: Hashable {
    let transport: TransportProtocol
    let guestPort: UInt16
}

public struct DesiredNetworkPolicy: Codable, Equatable, Sendable {
    public let environmentID: EnvironmentID
    public let runtimeInstanceID: RuntimeInstanceID
    public let version: PolicyVersion
    public let networkBaseline: NetworkBaseline
    public let lease: PolicyLease
    public let inboundPorts: [InboundPortAuthorization]

    public init(
        environmentID: EnvironmentID,
        runtimeInstanceID: RuntimeInstanceID,
        version: PolicyVersion,
        networkBaseline: NetworkBaseline,
        lease: PolicyLease,
        inboundPorts: [InboundPortAuthorization]
    ) {
        self.environmentID = environmentID
        self.runtimeInstanceID = runtimeInstanceID
        self.version = version
        self.networkBaseline = networkBaseline
        self.lease = lease
        self.inboundPorts = inboundPorts
    }

    public func validate() throws {
        guard !runtimeInstanceID.rawValue.isEmpty else {
            throw PolicyValidationFailure.runtimeInstanceIDMissing
        }
        try DesiredEnvironmentPolicy(
            environmentID: environmentID,
            version: version,
            networkBaseline: networkBaseline,
            lease: lease,
            inboundPorts: inboundPorts
        ).validate()
    }

    private enum CodingKeys: String, CodingKey {
        case environmentID = "environment_id"
        case runtimeInstanceID = "runtime_instance_id"
        case version
        case networkBaseline = "network_baseline"
        case lease
        case inboundPorts = "inbound_ports"
    }
}

public enum GuestAgentHealth: String, Codable, Equatable, Sendable {
    case healthy
    case unreachable
    case unknown
}

public enum AppliedPolicyStatus: String, Codable, Equatable, Sendable {
    case applying
    case enforced
    case failed
    case unknown
}

public struct AppliedNetworkPolicyEvidence: Codable, Equatable, Sendable {
    public let environmentID: EnvironmentID
    public let runtimeInstanceID: RuntimeInstanceID
    public let version: PolicyVersion?
    public let status: AppliedPolicyStatus
    public let agentHealth: GuestAgentHealth
    public let observedAtUnixMilliseconds: UInt64
    public let leaseRemainingMilliseconds: UInt64?
    public let failureCode: String?

    public init(
        environmentID: EnvironmentID,
        runtimeInstanceID: RuntimeInstanceID,
        version: PolicyVersion?,
        status: AppliedPolicyStatus,
        agentHealth: GuestAgentHealth,
        observedAtUnixMilliseconds: UInt64,
        leaseRemainingMilliseconds: UInt64?,
        failureCode: String? = nil
    ) {
        self.environmentID = environmentID
        self.runtimeInstanceID = runtimeInstanceID
        self.version = version
        self.status = status
        self.agentHealth = agentHealth
        self.observedAtUnixMilliseconds = observedAtUnixMilliseconds
        self.leaseRemainingMilliseconds = leaseRemainingMilliseconds
        self.failureCode = failureCode
    }

    private enum CodingKeys: String, CodingKey {
        case environmentID = "environment_id"
        case runtimeInstanceID = "runtime_instance_id"
        case version
        case status
        case agentHealth = "agent_health"
        case observedAtUnixMilliseconds = "observed_at_unix_milliseconds"
        case leaseRemainingMilliseconds = "lease_remaining_milliseconds"
        case failureCode = "failure_code"
    }
}

public struct AppliedSharePolicyEvidence: Codable, Equatable, Sendable {
    public let environmentID: EnvironmentID
    public let runtimeInstanceID: RuntimeInstanceID
    public let version: PolicyVersion?
    public let status: AppliedPolicyStatus
    public let observedAtUnixMilliseconds: UInt64
    public let failureCode: String?

    public init(
        environmentID: EnvironmentID,
        runtimeInstanceID: RuntimeInstanceID,
        version: PolicyVersion?,
        status: AppliedPolicyStatus,
        observedAtUnixMilliseconds: UInt64,
        failureCode: String? = nil
    ) {
        self.environmentID = environmentID
        self.runtimeInstanceID = runtimeInstanceID
        self.version = version
        self.status = status
        self.observedAtUnixMilliseconds = observedAtUnixMilliseconds
        self.failureCode = failureCode
    }

    private enum CodingKeys: String, CodingKey {
        case environmentID = "environment_id"
        case runtimeInstanceID = "runtime_instance_id"
        case version
        case status
        case observedAtUnixMilliseconds = "observed_at_unix_milliseconds"
        case failureCode = "failure_code"
    }
}
