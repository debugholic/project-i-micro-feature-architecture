import Foundation

public nonisolated struct APIConfig: NetworkConfigurable {
  public let baseURL: URL?
  public let headers: [String: String]
  public let queryParameters: [String: String]
  public let timeoutInterval: TimeInterval

  public init(
    baseURL: URL?,
    headers: [String: String] = [:],
    queryParameters: [String: String] = [:],
    timeoutInterval: TimeInterval = 30
  ) {
    self.baseURL = baseURL
    self.headers = headers
    self.queryParameters = queryParameters
    self.timeoutInterval = timeoutInterval
  }
}
