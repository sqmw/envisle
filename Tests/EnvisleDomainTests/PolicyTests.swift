import Foundation
import XCTest
@testable import EnvisleDomain

final class PolicyTests: XCTestCase {
    func testDefaultPolicyIsIsolatedAndValid() throws {
        let policy = Fixtures.policy()

        try policy.validate()
        XCTAssertEqual(policy.networkBaseline.hostInbound, .denyByDefault)
        XCTAssertEqual(policy.networkBaseline.guestPeers, .deny)
        XCTAssertTrue(policy.shares.isEmpty)
        XCTAssertTrue(policy.inboundPorts.isEmpty)
    }

    func testDuplicateAuthorizationAcrossBrokersIsRejected() {
        let id = AuthorizationID(rawValue: "grant-1")
        let policy = Fixtures.policy(
            shares: [
                ShareAuthorization(
                    id: id,
                    hostResourceID: "bookmark-1",
                    guestMountName: "documents"
                ),
            ],
            inboundPorts: [
                InboundPortAuthorization(id: id, transport: .tcp, guestPort: 8080),
            ]
        )

        XCTAssertThrowsError(try policy.validate()) { error in
            XCTAssertEqual(error as? PolicyValidationFailure, .duplicateAuthorizationID(id))
        }
    }

    func testInvalidLeaseAndPortAreRejected() {
        let invalidLease = DesiredEnvironmentPolicy(
            environmentID: Fixtures.environmentID,
            version: PolicyVersion(revision: 1, digest: "digest"),
            lease: PolicyLease(
                renewalIntervalMilliseconds: 5_000,
                failClosedAfterMilliseconds: 5_000
            )
        )
        XCTAssertThrowsError(try invalidLease.validate()) { error in
            XCTAssertEqual(error as? PolicyValidationFailure, .invalidLease)
        }

        let id = AuthorizationID(rawValue: "port-1")
        let invalidPort = Fixtures.policy(
            inboundPorts: [InboundPortAuthorization(id: id, transport: .tcp, guestPort: 0)]
        )
        XCTAssertThrowsError(try invalidPort.validate()) { error in
            XCTAssertEqual(error as? PolicyValidationFailure, .invalidGuestPort(id))
        }
    }

    func testGuestProtocolJSONHasStableSnakeCaseFieldsAndRoundTrips() throws {
        let request = GuestPolicyApplyRequest(
            requestID: "request-1",
            desiredPolicy: Fixtures.policy().networkProjection(for: Fixtures.runtimeInstanceID)
        )

        let data = try JSONEncoder().encode(request)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["protocol_version"] as? Int, 1)
        XCTAssertEqual(object["request_id"] as? String, "request-1")

        let desired = try XCTUnwrap(object["desired_policy"] as? [String: Any])
        XCTAssertEqual(desired["environment_id"] as? String, "environment-1")
        XCTAssertEqual(desired["runtime_instance_id"] as? String, "runtime-instance-1")
        XCTAssertNotNil(desired["network_baseline"])
        XCTAssertNotNil(desired["inbound_ports"])
        XCTAssertNil(desired["shares"])

        let decoded = try JSONDecoder().decode(GuestPolicyApplyRequest.self, from: data)
        XCTAssertEqual(decoded, request)
        try decoded.validate()

        let unsupported = GuestPolicyApplyRequest(
            protocolVersion: 2,
            requestID: "request-2",
            desiredPolicy: Fixtures.policy().networkProjection(for: Fixtures.runtimeInstanceID)
        )
        XCTAssertThrowsError(try unsupported.validate()) { error in
            XCTAssertEqual(
                error as? GuestPolicyRequestValidationFailure,
                .unsupportedProtocolVersion(2)
            )
        }
    }
}
