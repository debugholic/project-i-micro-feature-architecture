import DomainReservationInterface
import DomainReservationInterface
import Foundation

public final class MockReservationRepository: ReservationRepository {
  public enum Stub {
    case success(FlightLeg)
    case failure(Error)
  }

  private var stubs: [String: Stub] = [:]
  public private(set) var calls: [(date: Date, flightNumber: String)] = []

  public init() {}

  public func stub(_ flightNumber: String, with stub: Stub) {
    stubs[flightNumber] = stub
  }

  public nonisolated func fetchFlight(date: Date, flightNumber: String) async throws -> FlightLeg {
    calls.append((date, flightNumber))
    switch stubs[flightNumber] {
    case .success(let leg): return leg
    case .failure(let error): throw error
    case nil: throw ReservationError.notFound
    }
  }
}
