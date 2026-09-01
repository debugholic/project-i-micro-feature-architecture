import DomainReservationInterface
import DomainReservationInterface
import Foundation

public nonisolated struct DayPlan: Hashable, Identifiable {
  public let date: Date
  public let destination: DayPlanPlace
  public let items: [DayPlanItem]
  public let lodging: ItineraryItem?
  public let origin: DayPlanPlace

  public var id: Date { date }

  public init(
    date: Date,
    destination: DayPlanPlace,
    items: [DayPlanItem],
    lodging: ItineraryItem?,
    origin: DayPlanPlace
  ) {
    self.date = date
    self.destination = destination
    self.items = items
    self.lodging = lodging
    self.origin = origin
  }

  public var timelineItems: [DayPlanItem] {
    items.filter { item in
      guard let custom = item.itineraryItem else { return true }
      return custom.category == .place
    }
  }

  public var sights: [ItineraryItem] {
    items.compactMap(\.itineraryItem)
      .filter {
        $0.category == .place || $0.category == .sight
      }
  }

  public func meal(_ slot: MealSlot) -> ItineraryItem? {
    items.compactMap(\.itineraryItem)
      .first {
        $0.category == .meal(slot)
      }
  }
}

public nonisolated enum DayPlanItem: Hashable, Identifiable {
  case custom(ItineraryItem)
  case flight(FlightLeg, FlightPoint)

  public var id: String {
    switch self {
    case let .custom(item): return item.id.uuidString
    case let .flight(leg, point): return "\(leg.flightNumber)-\(point)"
    }
  }

  public var itineraryItem: ItineraryItem? {
    guard case let .custom(item) = self else { return nil }
    return item
  }

  public var startTime: Date {
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

public nonisolated enum DayPlanPlace: Hashable {
  case airport(Airport)
  case lodging(String)
}

public nonisolated enum FlightPoint: Hashable {
  case arrival
  case departure
}
