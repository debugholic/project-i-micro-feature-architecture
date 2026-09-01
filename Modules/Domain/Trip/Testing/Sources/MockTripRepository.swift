import DomainTripInterface

/// 테스트용 TripRepository — 호출 이력을 기록해 검증할 수 있게 한다.
public final class MockTripRepository: TripRepository {
  public private(set) var savedTrips: [Trip] = []
  public private(set) var removedTrips: [Trip] = []

  public init() {}

  public func save(_ trip: Trip) {
    savedTrips.append(trip)
  }

  public func remove(_ trip: Trip) {
    removedTrips.append(trip)
  }
}
