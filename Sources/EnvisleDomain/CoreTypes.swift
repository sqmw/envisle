import Foundation

public struct EnvironmentID: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(from decoder: any Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public struct ProviderID: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(from decoder: any Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public struct AuthorizationID: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(from decoder: any Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public struct RuntimeInstanceID: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(from decoder: any Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public enum HostOperatingSystem: String, Codable, Hashable, Sendable {
    case macOS = "macos"
    case windows
    case android
}

public enum GuestOperatingSystem: String, Codable, Hashable, Sendable {
    case linux
    case macOS = "macos"
    case windows
    case android
}

public enum MachineArchitecture: String, Codable, Hashable, Sendable {
    case arm64
    case x86_64
}

public enum RuntimeKind: String, Codable, Hashable, Sendable {
    case managedVirtualMachine = "managed_virtual_machine"
}

public struct EnvironmentPlacement: Codable, Equatable, Hashable, Sendable {
    public let hostOS: HostOperatingSystem
    public let hostArchitecture: MachineArchitecture
    public let guestOS: GuestOperatingSystem
    public let guestArchitecture: MachineArchitecture
    public let runtimeKind: RuntimeKind

    public init(
        hostOS: HostOperatingSystem,
        hostArchitecture: MachineArchitecture,
        guestOS: GuestOperatingSystem,
        guestArchitecture: MachineArchitecture,
        runtimeKind: RuntimeKind = .managedVirtualMachine
    ) {
        self.hostOS = hostOS
        self.hostArchitecture = hostArchitecture
        self.guestOS = guestOS
        self.guestArchitecture = guestArchitecture
        self.runtimeKind = runtimeKind
    }

    private enum CodingKeys: String, CodingKey {
        case hostOS = "host_os"
        case hostArchitecture = "host_architecture"
        case guestOS = "guest_os"
        case guestArchitecture = "guest_architecture"
        case runtimeKind = "runtime_kind"
    }
}

public struct EnvironmentSpecification: Codable, Equatable, Sendable {
    public let id: EnvironmentID
    public let name: String
    public let placement: EnvironmentPlacement

    public init(id: EnvironmentID, name: String, placement: EnvironmentPlacement) {
        self.id = id
        self.name = name
        self.placement = placement
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case placement
    }
}
