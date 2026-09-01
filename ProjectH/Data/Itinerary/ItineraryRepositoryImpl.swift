import Combine
import Foundation

final class ItineraryRepositoryImpl: ItineraryRepository {
  private let storage: ItineraryStorage

  init(storage: ItineraryStorage) {
    self.storage = storage
  }

  func itemsPublisher(for tripID: UUID) -> AnyPublisher<[ItineraryItem], Never> {
    storage.itemsPublisher(for: tripID)
  }

  func remove(_ item: ItineraryItem) {
    storage.delete(item)
  }

  func save(_ item: ItineraryItem) {
    storage.save(item)
  }
}
