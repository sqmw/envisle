import XCTest
@testable import EnvisleDomain

final class EnvironmentLifecycleTests: XCTestCase {
    func testHappyPathRequiresOrderedProviderEvidence() throws {
        var lifecycle = EnvironmentLifecycle()

        try lifecycle.apply(.preparationRequested)
        XCTAssertEqual(lifecycle.state, .preparing)
        try lifecycle.apply(.preparationSucceeded)
        XCTAssertEqual(lifecycle.state, .stopped)
        try lifecycle.apply(.startRequested)
        XCTAssertEqual(lifecycle.state, .starting)
        try lifecycle.apply(.runtimeStarted)
        XCTAssertEqual(lifecycle.state, .running)
        try lifecycle.apply(.stopRequested)
        XCTAssertEqual(lifecycle.state, .stopping)
        try lifecycle.apply(.runtimeStopped)
        XCTAssertEqual(lifecycle.state, .stopped)
        try lifecycle.apply(.deletionRequested)
        try lifecycle.apply(.deletionSucceeded)
        XCTAssertEqual(lifecycle.state, .deleted)
    }

    func testInvalidTransitionDoesNotChangeState() {
        var lifecycle = EnvironmentLifecycle()

        XCTAssertThrowsError(try lifecycle.apply(.runtimeStarted)) { error in
            XCTAssertEqual(
                error as? InvalidLifecycleTransition,
                InvalidLifecycleTransition(state: .defined, event: .runtimeStarted)
            )
        }
        XCTAssertEqual(lifecycle.state, .defined)
    }

    func testFailureMustBeReconciledBeforeRestart() throws {
        var lifecycle = EnvironmentLifecycle(state: .starting)

        try lifecycle.apply(.operationFailed)
        XCTAssertEqual(lifecycle.state, .failed)
        XCTAssertThrowsError(try lifecycle.apply(.startRequested))
        try lifecycle.apply(.reconciledStopped)
        try lifecycle.apply(.startRequested)
        XCTAssertEqual(lifecycle.state, .starting)
    }
}
