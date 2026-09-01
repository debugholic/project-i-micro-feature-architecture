import DomainReservationInterface
import Foundation
import SharedCommonTesting

public enum ReservationFixtures {
  public static func airport(
    city: String? = "Seoul",
    code: String? = "ICN",
    country: String? = "South Korea"
  ) -> Airport {
    Airport(city: city, code: code, country: country)
  }

  public static func movement(
    airport: Airport = ReservationFixtures.airport(),
    date: Date = TestDate.date,
    time: String? = "09:00"
  ) -> Movement {
    Movement(
      airport: airport,
      scheduledTime: ScheduledTime(date: date, time: time)
    )
  }

  public static func flightLeg(
    airline: String? = "Korean Air",
    arrival: Movement = ReservationFixtures.movement(
      airport: ReservationFixtures.airport(city: "Tokyo", code: "NRT", country: "Japan"),
      time: "11:30"
    ),
    departure: Movement = ReservationFixtures.movement(),
    flightNumber: String = "KE705"
  ) -> FlightLeg {
    FlightLeg(
      airline: airline,
      arrival: arrival,
      departure: departure,
      flightNumber: flightNumber
    )
  }
}
