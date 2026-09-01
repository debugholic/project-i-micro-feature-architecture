import DomainItineraryInterface
import DomainReservationInterface
import DomainTripInterface
import Foundation

struct DayPlanBuilder {
  let calendar: Calendar

  private var axis: DayPlanDateAxis {
    DayPlanDateAxis(calendar: calendar)
  }

  func build(
    trip: Trip,
    items: [ItineraryItem],
    lodgings: [Lodging],
    places: [TripPlace]
  ) -> [DayPlan] {
    let all = trip.flightItems + items.map(DayPlanItem.custom)
    let grouped = Dictionary(grouping: all) { calendar.startOfDay(for: $0.startTime) }
    let placesByDay = Dictionary(grouping: places) { calendar.startOfDay(for: $0.date) }

    return dayPlans(
      of: trip,
      grouped: grouped,
      lodgings: lodgings,
      placesByDay: placesByDay,
      on: axis.dates(
        of: trip,
        including: Set(grouped.keys).union(placesByDay.keys),
        lodgings: lodgings
      )
    )
  }

  private func dayPlans(
    of trip: Trip,
    grouped: [Date: [DayPlanItem]],
    lodgings: [Lodging],
    placesByDay: [Date: [TripPlace]],
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
        origin: origin,
        places: placesByDay[date] ?? []
      )
    }
  }
}
