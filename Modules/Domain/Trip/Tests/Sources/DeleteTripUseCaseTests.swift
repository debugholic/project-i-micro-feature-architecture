import DomainReservationTesting
import DomainTripInterface
import DomainTripTesting
import SharedCommonTesting
import XCTest
@testable import DomainTrip

final class DeleteTripUseCaseTests: XCTestCase {

  func test_execute_removesGivenTripFromRepository() async throws {
    let tripRepository = MockTripRepository()
    let trip = Trip(outbound: ReservationFixtures.flightLeg())
    let sut: any DeleteTripUseCase = DeleteTripUseCaseImpl(tripRepository: tripRepository)

    try await sut.execute(request: trip)

    XCTAssertEqual(tripRepository.removedTrips, [trip])
  }
}
