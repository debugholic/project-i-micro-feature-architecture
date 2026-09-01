import Foundation

nonisolated struct DayPlan: Hashable, Identifiable {
  let date: Date
  let destination: DayPlanPlace
  let items: [DayPlanItem]
  let lodging: ItineraryItem?
  let origin: DayPlanPlace

  var id: Date { date }

  var timelineItems: [DayPlanItem] {
    items.filter { item in
      guard let custom = item.itineraryItem else { return true }
      return custom.category == .place
    }
  }

  var sights: [ItineraryItem] {
    items
      .compactMap(\.itineraryItem)
      .filter { $0.category == .place || $0.category == .sight }
  }

  func meal(_ slot: MealSlot) -> ItineraryItem? {
    items.compactMap(\.itineraryItem).first { $0.category == .meal(slot) }
  }
}

nonisolated enum DayPlanItem: Hashable, Identifiable {
  case custom(ItineraryItem)
  case flight(FlightLeg, FlightPoint)

  var id: String {
    switch self {
    case let .custom(item): return item.id.uuidString
    case let .flight(leg, point): return "\(leg.flightNumber)-\(point)"
    }
  }

  var itineraryItem: ItineraryItem? {
    guard case let .custom(item) = self else { return nil }
    return item
  }

  var startTime: Date {
    switch self {
    case let .custom(item): return item.startTime
    case let .flight(leg, point):
      switch point {
      case .arrival: return leg.arrival.scheduledTime.date
      case .departure: return leg.departure.scheduledTime.date
      }
    }
  }
}

nonisolated enum DayPlanPlace: Hashable {
  case airport(Airport)
  case lodging(String)
}

nonisolated enum FlightPoint: Hashable {
  case arrival
  case departure
}
