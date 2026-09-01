import CoreStorage
import DomainItineraryInterface

public final class ItineraryRepositoryImpl: ItineraryRepository {
  private let storage: any Storage<ItineraryItem>

  public init(
    storage: any Storage<ItineraryItem>
  ) {
    self.storage = storage
  }

  public func remove(
    _ item: ItineraryItem
  ) {
    storage.delete(
      item
    )
  }

  public func save(
    _ item: ItineraryItem
  ) {
    storage.save(
      item
    )
  }
}
