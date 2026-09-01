import Combine
import Foundation

protocol ItineraryStorage {
  func itemsPublisher(for tripID: UUID) -> AnyPublisher<[ItineraryItem], Never>
  func save(_ item: ItineraryItem)
  func delete(_ item: ItineraryItem)
}
