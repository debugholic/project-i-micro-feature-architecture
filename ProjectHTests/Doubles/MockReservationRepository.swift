import Foundation
@testable import ProjectH

/// 편명별로 성공/실패를 미리 지정하고 호출 이력을 기록한다.
final class MockReservationRepository: ReservationRepository {
  enum Stub {
    case success(FlightLeg)
    case failure(Error)
  }

  private var stubs: [String: Stub] = [:]
  private(set) var calls: [(date: Date, flightNumber: String)] = []

  func stub(_ flightNumber: String, with stub: Stub) {
    stubs[flightNumber] = stub
  }

  nonisolated func fetchFlight(date: Date, flightNumber: String) async throws -> FlightLeg {
    calls.append((date, flightNumber))
    switch stubs[flightNumber] {
    case .success(let leg): return leg
    case .failure(let error): throw error
    case nil: throw ReservationError.notFound
    }
  }
}
