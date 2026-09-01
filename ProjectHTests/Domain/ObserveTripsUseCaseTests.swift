import Combine
import XCTest
@testable import ProjectH

final class ObserveTripsUseCaseTests: XCTestCase {

  private var cancellables = Set<AnyCancellable>()

  override func tearDown() {
    cancellables.removeAll()
    super.tearDown()
  }

  func test_execute_emitsValuesFromRepositoryPublisher() async throws {
    let tripRepository = MockTripRepository()
    let sut: any ObserveTripsUseCase = ObserveTripsUseCaseImpl(tripRepository: tripRepository)
    let trip = Trip(outbound: Fixtures.flightLeg())

    var received: [[Trip]] = []
    let publisher = try await sut.execute()
    publisher
      .sink { received.append($0) }
      .store(in: &cancellables)

    tripRepository.add(trip)

    XCTAssertEqual(received, [[], [trip]])
  }
}
