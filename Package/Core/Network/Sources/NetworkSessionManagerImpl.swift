import Foundation

public nonisolated struct NetworkSessionManagerImpl: NetworkSessionManager {
  private let session: URLSession

  public init(
    session: URLSession = .shared
  ) {
    self.session = session
  }

  public func data(
    for request: URLRequest
  ) async throws -> (Data, URLResponse) {
    try await session.data(
      for: request
    )
  }
}
