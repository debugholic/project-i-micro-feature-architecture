import Foundation

public nonisolated struct ItineraryItem: Codable, Hashable, Identifiable {
  public let category: ItineraryCategory
  public let endTime: Date?
  public let id: UUID
  public let location: String?
  public let startTime: Date
  public let title: String
  public let tripID: UUID

  public init(
    category: ItineraryCategory,
    endTime: Date? = nil,
    id: UUID = UUID(),
    location: String? = nil,
    startTime: Date,
    title: String,
    tripID: UUID
  ) {
    self.category = category
    self.endTime = endTime
    self.id = id
    self.location = location
    self.startTime = startTime
    self.title = title
    self.tripID = tripID
  }

  public func covers(
    _ date: Date,
    using calendar: Calendar
  ) -> Bool {
    guard let endTime else { return false }
    let day = calendar.startOfDay(for: date)
    return calendar.startOfDay(for: startTime) <= day
    && day < calendar.startOfDay(for: endTime)
  }
}
