public enum RuntimeCapability: String, Codable, CaseIterable, Hashable, Sendable {
    case create
    case start
    case stop
    case delete
    case observe
    case independentSystemDisk = "independent_system_disk"
    case readOnlyShareAtBoot = "read_only_share_at_boot"
    case guestPolicyAgent = "guest_policy_agent"
    case appliedNetworkPolicyQuery = "applied_network_policy_query"
    case appliedSharePolicyQuery = "applied_share_policy_query"
    case quarantine
}

public struct SupportedRuntime: Codable, Equatable, Hashable, Sendable {
    public let placement: EnvironmentPlacement

    public init(placement: EnvironmentPlacement) {
        self.placement = placement
    }
}

public struct ProviderDescriptor: Codable, Equatable, Sendable {
    public let id: ProviderID
    public let version: String
    public let priority: Int
    public let supportedRuntimes: Set<SupportedRuntime>
    public let capabilities: Set<RuntimeCapability>

    public init(
        id: ProviderID,
        version: String,
        priority: Int = 0,
        supportedRuntimes: Set<SupportedRuntime>,
        capabilities: Set<RuntimeCapability>
    ) {
        self.id = id
        self.version = version
        self.priority = priority
        self.supportedRuntimes = supportedRuntimes
        self.capabilities = capabilities
    }
}

public struct RuntimeRequirement: Equatable, Sendable {
    public let placement: EnvironmentPlacement
    public let requiredCapabilities: Set<RuntimeCapability>

    public init(
        placement: EnvironmentPlacement,
        requiredCapabilities: Set<RuntimeCapability>
    ) {
        self.placement = placement
        self.requiredCapabilities = requiredCapabilities
    }
}

public enum ProviderRejectionReason: Equatable, Sendable {
    case unsupportedPlacement(EnvironmentPlacement)
    case missingCapabilities(Set<RuntimeCapability>)
}

public struct ProviderEvaluation: Equatable, Sendable {
    public let providerID: ProviderID
    public let rejection: ProviderRejectionReason?

    public init(providerID: ProviderID, rejection: ProviderRejectionReason?) {
        self.providerID = providerID
        self.rejection = rejection
    }
}

public struct RuntimeRoutingDecision: Equatable, Sendable {
    public let selectedProvider: ProviderDescriptor
    public let evaluations: [ProviderEvaluation]

    public init(selectedProvider: ProviderDescriptor, evaluations: [ProviderEvaluation]) {
        self.selectedProvider = selectedProvider
        self.evaluations = evaluations
    }
}

public struct RuntimeRoutingFailure: Error, Equatable, Sendable {
    public let evaluations: [ProviderEvaluation]

    public init(evaluations: [ProviderEvaluation]) {
        self.evaluations = evaluations
    }
}

public enum RuntimeRouter {
    public static func route(
        requirement: RuntimeRequirement,
        providers: [ProviderDescriptor]
    ) throws -> RuntimeRoutingDecision {
        let ordered = providers.sorted {
            if $0.priority == $1.priority {
                return $0.id.rawValue < $1.id.rawValue
            }
            return $0.priority > $1.priority
        }

        let evaluations = ordered.map { provider in
            ProviderEvaluation(
                providerID: provider.id,
                rejection: rejection(for: provider, requirement: requirement)
            )
        }

        guard let selectedIndex = evaluations.firstIndex(where: { $0.rejection == nil }) else {
            throw RuntimeRoutingFailure(evaluations: evaluations)
        }

        return RuntimeRoutingDecision(
            selectedProvider: ordered[selectedIndex],
            evaluations: evaluations
        )
    }

    private static func rejection(
        for provider: ProviderDescriptor,
        requirement: RuntimeRequirement
    ) -> ProviderRejectionReason? {
        guard provider.supportedRuntimes.contains(SupportedRuntime(placement: requirement.placement)) else {
            return .unsupportedPlacement(requirement.placement)
        }
        let missing = requirement.requiredCapabilities.subtracting(provider.capabilities)
        guard missing.isEmpty else {
            return .missingCapabilities(missing)
        }
        return nil
    }
}

public struct ProviderResource: Codable, Equatable, Sendable {
    public let providerID: ProviderID
    public let providerResourceID: String
    public let rawState: String

    public init(providerID: ProviderID, providerResourceID: String, rawState: String) {
        self.providerID = providerID
        self.providerResourceID = providerResourceID
        self.rawState = rawState
    }
}

public enum FailureRetryability: String, Codable, Equatable, Sendable {
    case retryable
    case notRetryable = "not_retryable"
    case unknown
}

public struct ProviderFailure: Error, Codable, Equatable, Sendable {
    public let providerID: ProviderID
    public let operation: String
    public let code: String
    public let rawCode: String?
    public let message: String
    public let retryability: FailureRetryability

    public init(
        providerID: ProviderID,
        operation: String,
        code: String,
        rawCode: String? = nil,
        message: String,
        retryability: FailureRetryability
    ) {
        self.providerID = providerID
        self.operation = operation
        self.code = code
        self.rawCode = rawCode
        self.message = message
        self.retryability = retryability
    }
}

public protocol RuntimeProvider: Sendable {
    var descriptor: ProviderDescriptor { get }

    func create(specification: EnvironmentSpecification) async throws -> ProviderResource
    func start(resource: ProviderResource) async throws -> ProviderResource
    func stop(resource: ProviderResource) async throws -> ProviderResource
    func delete(resource: ProviderResource) async throws
    func observe(resource: ProviderResource) async throws -> ProviderResource
}
