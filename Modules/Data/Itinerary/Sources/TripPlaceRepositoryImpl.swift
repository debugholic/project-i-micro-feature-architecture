import CoreStorage
import DomainItineraryInterface

public final class TripPlaceRepositoryImpl: TripPlaceRepository {
  private let storage: any Storage<TripPlace>

  public init(
    storage: any Storage<TripPlace>
  ) {
    self.storage = storage
  }

  public func remove(
    _ place: TripPlace
  ) {
    storage.delete(
      place
    )
  }

  public func save(
    _ place: TripPlace
  ) {
    storage.save(
      place
    )
  }
}
