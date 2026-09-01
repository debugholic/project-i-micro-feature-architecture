import DomainItineraryInterface
import DomainTripInterface
import Foundation

struct DayPlanDateAxis {
  let calendar: Calendar

  func dates(
    of trip: Trip,
    including extra: Set<Date>,
    lodgings: [Lodging]
  ) -> [Date] {
    let start = calendar.startOfDay(for: trip.startDate)
    let end = calendar.startOfDay(for: trip.endDate)

    var result: Set<Date> = extra
    for lodging in lodgings {
      result.insert(calendar.startOfDay(for: lodging.checkIn))
    }

    var cursor = start
    while cursor <= end {
      result.insert(cursor)
      guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
      cursor = next
    }
    return result.sorted()
  }
}
