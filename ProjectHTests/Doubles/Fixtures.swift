import Foundation
@testable import ProjectH

enum Fixtures {

  static func airport(
    city: String? = "Seoul",
    code: String? = "ICN",
    country: String? = "South Korea"
  ) -> Airport {
    Airport(city: city, code: code, country: country)
  }

  static func movement(
    airport: Airport = Fixtures.airport(),
    date: Date = Fixtures.date,
    time: String? = "09:00"
  ) -> Movement {
    Movement(
      airport: airport,
      scheduledTime: ScheduledTime(date: date, time: time)
    )
  }

  static let date = Date(timeIntervalSince1970: 1_700_000_000)

  static func moment(
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
    return Calendar.current.date(from: components) ?? Fixtures.date
  }

  static func flightLeg(
    airline: String? = "Korean Air",
    arrival: Movement = Fixtures.movement(
      airport: Fixtures.airport(city: "Tokyo", code: "NRT", country: "Japan"),
      time: "11:30"
    ),
    departure: Movement = Fixtures.movement(),
    flightNumber: String = "KE705"
  ) -> FlightLeg {
    FlightLeg(
      airline: airline,
      arrival: arrival,
      departure: departure,
      flightNumber: flightNumber
    )
  }

  static func trip(
    outbound: FlightLeg = Fixtures.flightLeg(),
    returnLeg: FlightLeg? = nil
  ) -> Trip {
    Trip(outbound: outbound, returnLeg: returnLeg)
  }

  static func itineraryItem(
    category: ItineraryCategory = .place,
    endTime: Date? = nil,
    id: UUID = UUID(),
    location: String? = nil,
    startTime: Date = Fixtures.moment(),
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

  static func dayPlan(
    date: Date,
    destination: DayPlanPlace = .airport(Fixtures.airport()),
    items: [DayPlanItem] = [],
    lodging: ItineraryItem? = nil,
    origin: DayPlanPlace = .airport(Fixtures.airport())
  ) -> DayPlan {
    DayPlan(
      date: date,
      destination: destination,
      items: items,
      lodging: lodging,
      origin: origin
    )
  }

  static func lodging(
    checkIn: Date = Fixtures.moment(day: 15, hour: 15),
    checkOut: Date = Fixtures.moment(day: 16, hour: 11),
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
