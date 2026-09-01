import DomainItineraryInterface
import DomainRecommendationInterface
import DomainReservationInterface
import DomainReservationTesting
import Foundation
import SharedCommonTesting

public enum ItineraryFixtures {
  public static func itineraryItem(
    id: UUID = UUID(),
    mealSlot: MealSlot? = nil,
    placeID: UUID? = nil,
    startTime: Date = TestDate.moment(),
    title: String = "오도리 공원",
    tripID: UUID
  ) -> ItineraryItem {
    ItineraryItem(
      id: id,
      mealSlot: mealSlot,
      placeID: placeID,
      startTime: startTime,
      title: title,
      tripID: tripID
    )
  }

  public static func lodging(
    checkIn: Date = TestDate.moment(day: 15, hour: 15),
    checkOut: Date = TestDate.moment(day: 16, hour: 11),
    id: UUID = UUID(),
    location: String? = "Sapporo",
    name: String = "베셀 호텔",
    tripID: UUID
  ) -> Lodging {
    Lodging(
      checkIn: checkIn,
      checkOut: checkOut,
      id: id,
      location: location,
      name: name,
      tripID: tripID
    )
  }

  public static func place(
    category: PlaceCategory? = nil,
    date: Date = TestDate.moment(),
    id: UUID = UUID(),
    name: String = "다누키코지 상점가",
    tripID: UUID
  ) -> TripPlace {
    TripPlace(
      category: category,
      date: date,
      id: id,
      name: name,
      tripID: tripID
    )
  }

  public static func dayPlan(
    date: Date,
    destination: DayPlanPlace = .airport(ReservationFixtures.airport()),
    items: [DayPlanItem] = [],
    lodging: Lodging? = nil,
    origin: DayPlanPlace = .airport(ReservationFixtures.airport()),
    places: [TripPlace] = []
  ) -> DayPlan {
    DayPlan(
      date: date,
      destination: destination,
      items: items,
      lodging: lodging,
      origin: origin,
      places: places
    )
  }
}
