public nonisolated struct FlightLeg: Codable, Hashable {
  public let airline: String?
  public let arrival: Movement
  public let departure: Movement
  public let flightNumber: String

  public init(
    airline: String?,
    arrival: Movement,
    departure: Movement,
    flightNumber: String
  ) {
    self.airline = airline
    self.arrival = arrival
    self.departure = departure
    self.flightNumber = flightNumber
  }
}
