import DomainReservationInterface

public nonisolated enum ReservationFormatter {
  private static let unknownCity = "도착지"

  public static func cityName(
    _ airport: Airport
  ) -> String {
    airport.city ?? airport.code ?? unknownCity
  }
}
