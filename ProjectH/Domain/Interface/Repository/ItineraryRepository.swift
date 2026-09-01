import Combine
import Foundation

protocol ItineraryRepository {
  func itemsPublisher(for tripID: UUID) -> AnyPublisher<[ItineraryItem], Never>
  func remove(_ item: ItineraryItem)
  func save(_ item: ItineraryItem)
}
