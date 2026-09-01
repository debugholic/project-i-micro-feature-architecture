import Foundation

public enum TestDate {
  public static let date = Date(timeIntervalSince1970: 1_700_000_000)

  public static func moment(
    day: Int = 15,
    hour: Int = 9,
    minute: Int = 0
  ) -> Date {
    var components = DateComponents()
    components.year = 2025
    components.month = 7
    components.day = day
    components.hour = hour
    components.minute = minute
    return Calendar.current.date(from: components) ?? TestDate.date
  }
}
