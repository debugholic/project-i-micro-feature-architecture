import DomainRecommendationInterface
import Foundation

public nonisolated struct TripPlace: Codable, Hashable, Identifiable {
  public let category: PlaceCategory?
  public let date: Date
  public let id: UUID
  public let name: String
  public let tripID: UUID

  public init(
    category: PlaceCategory? = nil,
    date: Date,
    id: UUID = UUID(),
    name: String,
    tripID: UUID
  ) {
    self.category = category
    self.date = date
    self.id = id
    self.name = name
    self.tripID = tripID
  }
}
