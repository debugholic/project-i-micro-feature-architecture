import DomainItineraryInterface
import DomainRecommendationInterface
import DomainReservationInterface
import DomainTripInterface
import FeatureReservationInterface
import Foundation
import SharedCommon

nonisolated enum ItineraryFormatter {
  static func dayLabel(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "M/d (E)"
    return formatter.string(from: date)
  }

  static func route(_ plan: DayPlan) -> String {
    "\(placeName(plan.origin)) | \(placeName(plan.destination))"
  }

  static func placeName(_ place: DayPlanPlace) -> String {
    switch place {
    case let .airport(airport): return ReservationFormatter.cityName(airport)
    case let .lodging(name): return name
    }
  }

  static func hourLabel(_ hour: Int) -> String {
    String(format: "%02d", hour)
  }

  static func time(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
  }

  static func dayTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "M월 d일 (E) HH:mm"
    return formatter.string(from: date)
  }

  static func dayRange(from: Date, to: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "M월 d일"
    return "\(formatter.string(from: from)) ~ \(formatter.string(from: to))"
  }

  static func mealName(_ slot: MealSlot) -> String {
    switch slot {
    case .breakfast: return "아침"
    case .lunch: return "점심"
    case .dinner: return "저녁"
    case .lateNight: return "야식"
    }
  }

  static func symbol(_ item: ItineraryItem) -> String {
    item.mealSlot == nil ? "mappin.and.ellipse" : "fork.knife"
  }

  static func title(_ item: DayPlanItem) -> String {
    switch item {
    case let .custom(item): return item.title
    case let .flight(leg, point):
      let name = point == .departure ? "출발" : "도착"
      return "\(name) · \(leg.flightNumber)"
    }
  }

  static func subtitle(_ item: DayPlanItem) -> String? {
    switch item {
    case .custom: return nil
    case let .flight(leg, point):
      switch point {
      case .arrival: return ReservationFormatter.cityName(leg.arrival.airport)
      case .departure:
        return "\(ReservationFormatter.cityName(leg.departure.airport)) → \(ReservationFormatter.cityName(leg.arrival.airport))"
      }
    }
  }
}
