import Foundation

public nonisolated enum NetworkError: Error {
  case invalidURL
  case invalidResponse
  case statusCode(Int, Data?)

  public var statusCode: Int? {
    if case .statusCode(let code, _) = self { return code }
    return nil
  }
}
