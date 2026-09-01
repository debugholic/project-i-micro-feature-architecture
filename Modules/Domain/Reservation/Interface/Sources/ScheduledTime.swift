import Foundation

public nonisolated struct ScheduledTime: Codable, Hashable {
  public let date: Date
  public let time: String?

  public init(
    date: Date,
    time: String?
  ) {
    self.date = date
    self.time = time
  }
}
