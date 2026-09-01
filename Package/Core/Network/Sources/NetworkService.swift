import Foundation

public protocol NetworkService: Sendable {
  nonisolated func request(
    endpoint: Requestable
  ) async throws -> Data
}
