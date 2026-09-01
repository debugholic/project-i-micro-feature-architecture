import Combine
import DomainReservationTesting
import DomainTripInterface
import DomainTripTesting
import FeatureTripInterface
import SharedCommonTesting
import XCTest
@testable import FeatureTrip

final class TripListViewModelTests: XCTestCase {

  private var cancellables = Set<AnyCancellable>()

  override func tearDown() {
    cancellables.removeAll()
    super.tearDown()
  }

  private func makeSUT(
    deleteTripUseCase: MockDeleteTripUseCase = MockDeleteTripUseCase(),
    trips: AnyPublisher<[Trip], Never> = Empty().eraseToAnyPublisher(),
    showAddReservation: @escaping () -> Void = {},
    showCalendar: @escaping (Trip) -> Void = { _ in }
  ) -> TripListViewModel {
    TripListViewModel(
      actions: TripListViewModelActions(
        showAddReservation: showAddReservation,
        showCalendar: showCalendar
      ),
      deleteTripUseCase: deleteTripUseCase,
      trips: trips
    )
  }

  func test_init_updatesTripsWhenUseCaseEmits() {
    let trip = Trip(outbound: ReservationFixtures.flightLeg())
    let subject = CurrentValueSubject<[Trip], Never>([trip])

    let sut = makeSUT(trips: subject.eraseToAnyPublisher())

    let received = expectation(description: "trips 반영")
    sut.$trips
      .filter { $0 == [trip] }
      .first()
      .sink { _ in received.fulfill() }
      .store(in: &cancellables)

    wait(for: [received], timeout: 2.0)
  }

  func test_didDeleteTrip_passesTripToUseCase() {
    let deleteTripUseCase = MockDeleteTripUseCase()
    let sut = makeSUT(deleteTripUseCase: deleteTripUseCase)
    let trip = Trip(outbound: ReservationFixtures.flightLeg())

    sut.didDeleteTrip(trip)

    let deleted = expectation(description: "삭제 전달")
    DispatchQueue.main.async {
      XCTAssertEqual(deleteTripUseCase.deletedTrips, [trip])
      deleted.fulfill()
    }
    wait(for: [deleted], timeout: 1.0)
  }

  func test_didTapAddReservation_requestsFlow() {
    var requested = false
    let sut = makeSUT(showAddReservation: { requested = true })

    sut.didTapAddReservation()

    XCTAssertTrue(requested)
  }

  func test_didSelectTrip_requestsCalendarFlow() {
    let trip = Trip(outbound: ReservationFixtures.flightLeg())
    var selected: Trip?
    let sut = makeSUT(showCalendar: { selected = $0 })

    sut.didSelectTrip(trip)

    XCTAssertEqual(selected, trip)
  }
}
