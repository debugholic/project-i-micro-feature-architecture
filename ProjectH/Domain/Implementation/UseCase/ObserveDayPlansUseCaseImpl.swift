import Combine
import Foundation

struct ObserveDayPlansUseCaseImpl: ObserveDayPlansUseCase {
  private let calendar: Calendar
  private let itineraryRepository: ItineraryRepository

  init(
    calendar: Calendar = .current,
    itineraryRepository: ItineraryRepository
  ) {
    self.calendar = calendar
    self.itineraryRepository = itineraryRepository
  }

  func execute(
    request trip: Trip
  ) -> AnyPublisher<[DayPlan], Never> {
    itineraryRepository.itemsPublisher(
      for: trip.id
    )
    .map { items in
      let lodgings = items.filter { $0.category == .lodging }
      let scheduled = items.filter { $0.category != .lodging }
      let all = flightItems(of: trip) + scheduled.map(DayPlanItem.custom)
      let grouped = Dictionary(grouping: all) { calendar.startOfDay(for: $0.startTime) }
      
      return dayPlans(
        of: trip,
        grouped: grouped,
        lodgings: lodgings,
        on: dates(
          of: trip,
          including: Set(grouped.keys),
          lodgings: lodgings
        )
      )
    }
    .eraseToAnyPublisher()
  }

  private func dayPlans(
    of trip: Trip,
    grouped: [Date: [DayPlanItem]],
    lodgings: [ItineraryItem],
    on dates: [Date]
  ) -> [DayPlan] {
    var origin: DayPlanPlace = .airport(trip.outbound.departure.airport)

    return dates.map { date in
      let items = (grouped[date] ?? []).sorted { $0.startTime < $1.startTime }
      let lodging = lodgings.first { $0.covers(date, using: calendar) }

      let arrival = items.reduce(origin) { current, item in
        guard case let .flight(leg, .arrival) = item else { return current }
        return .airport(leg.arrival.airport)
      }
      let destination = lodging?.location.map(DayPlanPlace.lodging) ?? arrival
      defer { origin = destination }

      return DayPlan(
        date: date,
        destination: destination,
        items: items,
        lodging: lodging,
        origin: origin
      )
    }
  }

  private func flightItems(of trip: Trip) -> [DayPlanItem] {
    var result: [DayPlanItem] = [
      .flight(trip.outbound, .departure),
      .flight(trip.outbound, .arrival),
    ]
    if let returnLeg = trip.returnLeg {
      result.append(.flight(returnLeg, .departure))
      result.append(.flight(returnLeg, .arrival))
    }
    return result
  }

  private func dates(
    of trip: Trip,
    including extra: Set<Date>,
    lodgings: [ItineraryItem]
  ) -> [Date] {
    let start = calendar.startOfDay(for: trip.startDate)
    let end = calendar.startOfDay(for: trip.endDate)

    var result: Set<Date> = extra
    for lodging in lodgings {
      result.insert(calendar.startOfDay(for: lodging.startTime))
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
