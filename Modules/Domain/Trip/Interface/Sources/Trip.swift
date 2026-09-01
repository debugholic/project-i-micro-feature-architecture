import DomainReservationInterface
import Foundation

public nonisolated struct Trip: Codable, Hashable, Identifiable {
  public let id: UUID
  public let outbound: FlightLeg
  public let returnLeg: FlightLeg?

  public init(
    id: UUID = UUID(),
    outbound: FlightLeg,
    returnLeg: FlightLeg? = nil
  ) {
    self.id = id
    self.outbound = outbound
    self.returnLeg = returnLeg
  }

  public var destination: Airport { outbound.arrival.airport }

  public var isRoundTrip: Bool { returnLeg != nil }

  public var startDate: Date { outbound.departure.scheduledTime.date }
  public var endDate: Date { returnLeg?.departure.scheduledTime.date ?? startDate }

  public func totalDays(
    using calendar: Calendar
  ) -> Int {
    let from = calendar.startOfDay(
      for: startDate
    )
    let to = calendar.startOfDay(
      for: endDate
    )
    let nights = calendar.dateComponents(
      [.day],
      from: from,
      to: to
    ).day ?? 0
    return nights + 1
  }
}
