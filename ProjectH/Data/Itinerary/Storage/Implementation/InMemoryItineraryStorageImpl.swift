import Combine
import Foundation

final class InMemoryItineraryStorageImpl: ItineraryStorage {
  @Published private var items: [ItineraryItem] = []

  func itemsPublisher(for tripID: UUID) -> AnyPublisher<[ItineraryItem], Never> {
    $items
      .map { items in items.filter { $0.tripID == tripID } }
      .eraseToAnyPublisher()
  }

  func save(_ item: ItineraryItem) {
    guard let index = items.firstIndex(where: { $0.id == item.id }) else {
      items.append(item)
      return
    }
    items[index] = item
  }

  func delete(_ item: ItineraryItem) {
    items.removeAll { $0.id == item.id }
  }
}
