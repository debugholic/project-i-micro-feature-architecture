import Combine
import Foundation
@testable import ProjectH

final class MockItineraryRepository: ItineraryRepository {
  @Published private var items: [ItineraryItem] = []

  private(set) var removedItems: [ItineraryItem] = []
  private(set) var savedItems: [ItineraryItem] = []

  func save(_ item: ItineraryItem) {
    savedItems.append(item)
    guard let index = items.firstIndex(where: { $0.id == item.id }) else {
      items.append(item)
      return
    }
    items[index] = item
  }

  func itemsPublisher(for tripID: UUID) -> AnyPublisher<[ItineraryItem], Never> {
    $items
      .map { items in items.filter { $0.tripID == tripID } }
      .eraseToAnyPublisher()
  }

  func remove(_ item: ItineraryItem) {
    removedItems.append(item)
    items.removeAll { $0.id == item.id }
  }
}
