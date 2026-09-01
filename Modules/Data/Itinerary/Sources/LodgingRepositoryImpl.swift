import CoreStorage
import DomainItineraryInterface

public final class LodgingRepositoryImpl: LodgingRepository {
  private let storage: any Storage<Lodging>

  public init(
    storage: any Storage<Lodging>
  ) {
    self.storage = storage
  }

  public func remove(
    _ lodging: Lodging
  ) {
    storage.delete(
      lodging
    )
  }

  public func save(
    _ lodging: Lodging
  ) {
    storage.save(
      lodging
    )
  }
}
