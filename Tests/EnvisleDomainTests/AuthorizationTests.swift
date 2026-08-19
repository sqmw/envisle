import XCTest
@testable import EnvisleDomain

final class AuthorizationTests: XCTestCase {
    func testShareAndPortAuthorizationMustBeExplicitAndRevocable() throws {
        var authorizations = try EnvironmentAuthorizations()
        let share = ShareAuthorization(
            id: AuthorizationID(rawValue: "share-1"),
            hostResourceID: "bookmark-1",
            guestMountName: "documents"
        )
        let port = InboundPortAuthorization(
            id: AuthorizationID(rawValue: "port-1"),
            transport: .tcp,
            guestPort: 8080
        )

        XCTAssertTrue(authorizations.shares.isEmpty)
        XCTAssertTrue(authorizations.inboundPorts.isEmpty)

        try authorizations.authorize(share)
        try authorizations.authorize(port)
        XCTAssertEqual(authorizations.shares, [share])
        XCTAssertEqual(authorizations.inboundPorts, [port])

        XCTAssertTrue(authorizations.revoke(share.id))
        XCTAssertTrue(authorizations.revoke(port.id))
        XCTAssertFalse(authorizations.revoke(port.id))
        XCTAssertTrue(authorizations.shares.isEmpty)
        XCTAssertTrue(authorizations.inboundPorts.isEmpty)
    }

    func testAuthorizationIDCannotBeReusedAcrossShareAndPort() throws {
        let id = AuthorizationID(rawValue: "grant-1")
        var authorizations = try EnvironmentAuthorizations(
            shares: [
                ShareAuthorization(
                    id: id,
                    hostResourceID: "bookmark-1",
                    guestMountName: "documents"
                ),
            ]
        )

        XCTAssertThrowsError(
            try authorizations.authorize(
                InboundPortAuthorization(id: id, transport: .tcp, guestPort: 8080)
            )
        ) { error in
            XCTAssertEqual(error as? PolicyValidationFailure, .duplicateAuthorizationID(id))
        }
    }
}
