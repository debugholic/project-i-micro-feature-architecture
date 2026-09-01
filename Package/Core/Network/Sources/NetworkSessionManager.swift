import Foundation

public protocol NetworkSessionManager: Sendable {
  nonisolated func data(
    for request: URLRequest
  ) async throws -> (Data, URLResponse)
}
