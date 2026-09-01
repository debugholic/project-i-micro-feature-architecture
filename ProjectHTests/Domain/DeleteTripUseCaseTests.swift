import XCTest
@testable import ProjectH

final class DeleteTripUseCaseTests: XCTestCase {

  func test_execute_removesGivenTripFromRepository() async throws {
    let tripRepository = MockTripRepository()
    let trip = Trip(outbound: Fixtures.flightLeg())
    let sut: any DeleteTripUseCase = DeleteTripUseCaseImpl(tripRepository: tripRepository)

    try await sut.execute(request: trip)

    XCTAssertEqual(tripRepository.removedTrips, [trip])
  }
}
