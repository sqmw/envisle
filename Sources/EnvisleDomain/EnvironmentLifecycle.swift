public enum EnvironmentLifecycleState: String, Codable, Equatable, Sendable {
    case defined
    case preparing
    case stopped
    case starting
    case running
    case stopping
    case deleting
    case deleted
    case failed
}

public enum EnvironmentLifecycleEvent: String, Codable, Equatable, Sendable {
    case preparationRequested = "preparation_requested"
    case preparationSucceeded = "preparation_succeeded"
    case startRequested = "start_requested"
    case runtimeStarted = "runtime_started"
    case stopRequested = "stop_requested"
    case runtimeStopped = "runtime_stopped"
    case deletionRequested = "deletion_requested"
    case deletionSucceeded = "deletion_succeeded"
    case operationFailed = "operation_failed"
    case reconciledStopped = "reconciled_stopped"
    case reconciledDeleted = "reconciled_deleted"
}

public struct InvalidLifecycleTransition: Error, Equatable, Sendable {
    public let state: EnvironmentLifecycleState
    public let event: EnvironmentLifecycleEvent

    public init(state: EnvironmentLifecycleState, event: EnvironmentLifecycleEvent) {
        self.state = state
        self.event = event
    }
}

public struct EnvironmentLifecycle: Codable, Equatable, Sendable {
    public private(set) var state: EnvironmentLifecycleState

    public init(state: EnvironmentLifecycleState = .defined) {
        self.state = state
    }

    public mutating func apply(_ event: EnvironmentLifecycleEvent) throws {
        guard let nextState = Self.transition(from: state, event: event) else {
            throw InvalidLifecycleTransition(state: state, event: event)
        }
        state = nextState
    }

    private static func transition(
        from state: EnvironmentLifecycleState,
        event: EnvironmentLifecycleEvent
    ) -> EnvironmentLifecycleState? {
        switch (state, event) {
        case (.defined, .preparationRequested): .preparing
        case (.preparing, .preparationSucceeded): .stopped
        case (.stopped, .startRequested): .starting
        case (.starting, .runtimeStarted): .running
        case (.running, .stopRequested): .stopping
        case (.stopping, .runtimeStopped): .stopped
        case (.defined, .deletionRequested), (.stopped, .deletionRequested): .deleting
        case (.deleting, .deletionSucceeded): .deleted
        case (.preparing, .operationFailed), (.starting, .operationFailed), (.running, .operationFailed),
             (.stopping, .operationFailed), (.deleting, .operationFailed): .failed
        case (.failed, .reconciledStopped): .stopped
        case (.failed, .reconciledDeleted): .deleted
        default: nil
        }
    }
}
