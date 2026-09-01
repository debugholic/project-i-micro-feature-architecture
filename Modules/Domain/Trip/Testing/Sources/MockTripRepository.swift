import DomainTripInterface

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
