import Foundation

public nonisolated struct Lodging: Codable, Hashable, Identifiable {
  public let checkIn: Date
  public let checkOut: Date
  public let id: UUID
  public let location: String?
  public let name: String
  public let tripID: UUID

  public init(
    checkIn: Date,
    checkOut: Date,
    id: UUID = UUID(),
    location: String? = nil,
    name: String,
    tripID: UUID
  ) {
    self.checkIn = checkIn
    self.checkOut = checkOut
    self.id = id
    self.location = location
    self.name = name
    self.tripID = tripID
  }

  public func covers(
    _ date: Date,
    using calendar: Calendar
  ) -> Bool {
    let day = calendar.startOfDay(for: date)
    return calendar.startOfDay(for: checkIn) <= day
      && day < calendar.startOfDay(for: checkOut)
  }
}
