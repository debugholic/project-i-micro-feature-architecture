import Foundation

nonisolated struct ItineraryItem: Hashable, Identifiable {
  let category: ItineraryCategory
  let endTime: Date?
  let id: UUID
  let location: String?
  let startTime: Date
  let title: String
  let tripID: UUID

  init(
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

  func covers(_ date: Date, using calendar: Calendar) -> Bool {
    guard let endTime else { return false }
    let day = calendar.startOfDay(for: date)
    return calendar.startOfDay(for: startTime) <= day && day < calendar.startOfDay(for: endTime)
  }
}
