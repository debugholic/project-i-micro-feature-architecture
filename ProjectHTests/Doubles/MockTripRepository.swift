import Combine
@testable import ProjectH

/// 테스트용 TripRepository — 호출 이력을 기록해 검증할 수 있게 한다.
final class MockTripRepository: TripRepository {
  @Published private var trips: [Trip] = []
  var tripsPublisher: AnyPublisher<[Trip], Never> { $trips.eraseToAnyPublisher() }

  private(set) var addedTrips: [Trip] = []
  private(set) var removedTrips: [Trip] = []

  func add(_ trip: Trip) {
    trips.append(trip)
    addedTrips.append(trip)
  }

  func remove(_ trip: Trip) {
    trips.removeAll { $0.id == trip.id }
    removedTrips.append(trip)
  }
}
