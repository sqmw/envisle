import Foundation
import XCTest
@testable import EnvisleDomain

final class GuestPolicyProtocolTests: XCTestCase {
    func testAllFourMessagesRoundTripAndResponsesCorrelate() throws {
        let applyRequest = GuestPolicyApplyRequest(
            requestID: "apply-1",
            desiredPolicy: Fixtures.policy().networkProjection(for: Fixtures.runtimeInstanceID)
        )
        let applyResponse = GuestPolicyApplyResponse(
            requestID: applyRequest.requestID,
            receipt: NetworkPolicyApplicationReceipt(
                environmentID: Fixtures.environmentID,
                runtimeInstanceID: Fixtures.runtimeInstanceID,
                acceptedVersion: Fixtures.policy().version
            )
        )
        let observeRequest = GuestPolicyObserveRequest(
            requestID: "observe-1",
            environmentID: Fixtures.environmentID,
            runtimeInstanceID: Fixtures.runtimeInstanceID
        )
        let observeResponse = GuestPolicyObserveResponse(
            requestID: observeRequest.requestID,
            evidence: Fixtures.appliedNetwork()
        )

        try applyRequest.validate()
        try applyResponse.validate(matching: applyRequest)
        try observeRequest.validate()
        try observeResponse.validate(matching: observeRequest)

        try assertRoundTrip(applyRequest)
        try assertRoundTrip(applyResponse)
        try assertRoundTrip(observeRequest)
        try assertRoundTrip(observeResponse)
    }

    func testApplyResponseRejectsUnknownVersionAndRequestOrPolicyMismatch() {
        let request = GuestPolicyApplyRequest(
            requestID: "apply-1",
            desiredPolicy: Fixtures.policy().networkProjection(for: Fixtures.runtimeInstanceID)
        )
        let receipt = NetworkPolicyApplicationReceipt(
            environmentID: Fixtures.environmentID,
            runtimeInstanceID: Fixtures.runtimeInstanceID,
            acceptedVersion: Fixtures.policy().version
        )

        assertApplyResponse(
            GuestPolicyApplyResponse(protocolVersion: 2, requestID: request.requestID, receipt: receipt),
            rejectsAgainst: request,
            as: .unsupportedProtocolVersion(2)
        )
        assertApplyResponse(
            GuestPolicyApplyResponse(requestID: "other", receipt: receipt),
            rejectsAgainst: request,
            as: .requestIDMismatch
        )
        assertApplyResponse(
            GuestPolicyApplyResponse(
                requestID: request.requestID,
                receipt: NetworkPolicyApplicationReceipt(
                    environmentID: Fixtures.otherEnvironmentID,
                    runtimeInstanceID: Fixtures.runtimeInstanceID,
                    acceptedVersion: Fixtures.policy().version
                )
            ),
            rejectsAgainst: request,
            as: .environmentIDMismatch
        )
        assertApplyResponse(
            GuestPolicyApplyResponse(
                requestID: request.requestID,
                receipt: NetworkPolicyApplicationReceipt(
                    environmentID: Fixtures.environmentID,
                    runtimeInstanceID: Fixtures.previousRuntimeInstanceID,
                    acceptedVersion: Fixtures.policy().version
                )
            ),
            rejectsAgainst: request,
            as: .runtimeInstanceIDMismatch
        )
        assertApplyResponse(
            GuestPolicyApplyResponse(
                requestID: request.requestID,
                receipt: NetworkPolicyApplicationReceipt(
                    environmentID: Fixtures.environmentID,
                    runtimeInstanceID: Fixtures.runtimeInstanceID,
                    acceptedVersion: PolicyVersion(revision: 3, digest: "old")
                )
            ),
            rejectsAgainst: request,
            as: .policyVersionMismatch
        )
    }

    func testObserveResponseRejectsUnknownVersionAndRequestOrRuntimeMismatch() {
        let request = GuestPolicyObserveRequest(
            requestID: "observe-1",
            environmentID: Fixtures.environmentID,
            runtimeInstanceID: Fixtures.runtimeInstanceID
        )

        assertObserveResponse(
            GuestPolicyObserveResponse(
                protocolVersion: 2,
                requestID: request.requestID,
                evidence: Fixtures.appliedNetwork()
            ),
            rejectsAgainst: request,
            as: .unsupportedProtocolVersion(2)
        )
        assertObserveResponse(
            GuestPolicyObserveResponse(
                requestID: "other",
                evidence: Fixtures.appliedNetwork()
            ),
            rejectsAgainst: request,
            as: .requestIDMismatch
        )
        assertObserveResponse(
            GuestPolicyObserveResponse(
                requestID: request.requestID,
                evidence: Fixtures.appliedNetwork(environmentID: Fixtures.otherEnvironmentID)
            ),
            rejectsAgainst: request,
            as: .environmentIDMismatch
        )
        assertObserveResponse(
            GuestPolicyObserveResponse(
                requestID: request.requestID,
                evidence: Fixtures.appliedNetwork(
                    runtimeInstanceID: Fixtures.previousRuntimeInstanceID
                )
            ),
            rejectsAgainst: request,
            as: .runtimeInstanceIDMismatch
        )
    }

    private func assertRoundTrip<Value: Codable & Equatable>(_ value: Value) throws {
        let data = try JSONEncoder().encode(value)
        XCTAssertEqual(try JSONDecoder().decode(Value.self, from: data), value)
    }

    private func assertApplyResponse(
        _ response: GuestPolicyApplyResponse,
        rejectsAgainst request: GuestPolicyApplyRequest,
        as expected: GuestPolicyResponseValidationFailure
    ) {
        XCTAssertThrowsError(try response.validate(matching: request)) { error in
            XCTAssertEqual(error as? GuestPolicyResponseValidationFailure, expected)
        }
    }

    private func assertObserveResponse(
        _ response: GuestPolicyObserveResponse,
        rejectsAgainst request: GuestPolicyObserveRequest,
        as expected: GuestPolicyResponseValidationFailure
    ) {
        XCTAssertThrowsError(try response.validate(matching: request)) { error in
            XCTAssertEqual(error as? GuestPolicyResponseValidationFailure, expected)
        }
    }
}
