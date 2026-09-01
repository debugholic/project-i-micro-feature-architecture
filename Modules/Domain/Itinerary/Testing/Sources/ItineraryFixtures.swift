import DomainItineraryInterface
import DomainReservationInterface
import DomainReservationTesting
import Foundation
import SharedCommonTesting

public enum ItineraryFixtures {
  public static func itineraryItem(
    category: ItineraryCategory = .place,
    endTime: Date? = nil,
    id: UUID = UUID(),
    location: String? = nil,
    startTime: Date = TestDate.moment(),
    title: String = "오도리 공원",
    tripID: UUID
  ) -> ItineraryItem {
    ItineraryItem(
      category: category,
      endTime: endTime,
      id: id,
      location: location,
      startTime: startTime,
      title: title,
      tripID: tripID
    )
  }

  public static func dayPlan(
    date: Date,
    destination: DayPlanPlace = .airport(ReservationFixtures.airport()),
    items: [DayPlanItem] = [],
    lodging: ItineraryItem? = nil,
    origin: DayPlanPlace = .airport(ReservationFixtures.airport())
  ) -> DayPlan {
    DayPlan(
      date: date,
      destination: destination,
      items: items,
      lodging: lodging,
      origin: origin
    )
  }

  public static func lodging(
    checkIn: Date = TestDate.moment(day: 15, hour: 15),
    checkOut: Date = TestDate.moment(day: 16, hour: 11),
    location: String? = "Sapporo",
    title: String = "베셀 호텔",
    tripID: UUID
  ) -> ItineraryItem {
    ItineraryItem(
      category: .lodging,
      endTime: checkOut,
      location: location,
      startTime: checkIn,
      title: title,
      tripID: tripID
    )
  }

}
