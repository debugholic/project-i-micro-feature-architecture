import Combine
import DomainItineraryInterface
import Foundation

public final class MockItineraryRepository: ItineraryRepository {
  @Published private var items: [ItineraryItem] = []

  public private(set) var removedItems: [ItineraryItem] = []
  public private(set) var savedItems: [ItineraryItem] = []

  public var itemsPublisher: AnyPublisher<[ItineraryItem], Never> {
    $items.eraseToAnyPublisher()
  }

  public init() {}

  public func save(_ item: ItineraryItem) {
    savedItems.append(item)
    guard let index = items.firstIndex(where: { $0.id == item.id }) else {
      items.append(item)
      return
    }
    items[index] = item
  }

  public func remove(_ item: ItineraryItem) {
    removedItems.append(item)
    items.removeAll { $0.id == item.id }
  }
}
