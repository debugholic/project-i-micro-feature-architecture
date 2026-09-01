import Foundation

public nonisolated struct ItineraryItem: Codable, Hashable, Identifiable {
  public let id: UUID
  public let mealSlot: MealSlot?
  public let placeID: UUID?
  public let startTime: Date
  public let title: String
  public let tripID: UUID

  public init(
    id: UUID = UUID(),
    mealSlot: MealSlot? = nil,
    placeID: UUID? = nil,
    startTime: Date,
    title: String,
    tripID: UUID
  ) {
    self.id = id
    self.mealSlot = mealSlot
    self.placeID = placeID
    self.startTime = startTime
    self.title = title
    self.tripID = tripID
  }
}
