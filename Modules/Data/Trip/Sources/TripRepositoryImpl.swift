import CoreStorage
import DomainTripInterface

public final class TripRepositoryImpl: TripRepository {
  private let storage: any Storage<Trip>

  public init(
    storage: any Storage<Trip>
  ) {
    self.storage = storage
  }

  public func save(
    _ trip: Trip
  ) {
    storage.save(
      trip
    )
  }

  public func remove(
    _ trip: Trip
  ) {
    storage.delete(
      trip
    )
  }
}
