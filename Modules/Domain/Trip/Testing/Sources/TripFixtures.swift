import DomainReservationInterface
import DomainReservationTesting
import DomainTripInterface

public enum TripFixtures {
  public static func trip(
    outbound: FlightLeg = ReservationFixtures.flightLeg(),
    returnLeg: FlightLeg? = nil
  ) -> Trip {
    Trip(outbound: outbound, returnLeg: returnLeg)
  }
}
