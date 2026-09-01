import Foundation

public protocol NetworkConfigurable: Sendable {
  nonisolated var baseURL: URL? { get }
  nonisolated var headers: [String: String] { get }
  nonisolated var queryParameters: [String: String] { get }
  nonisolated var timeoutInterval: TimeInterval { get }
}

extension NetworkConfigurable {
  public nonisolated var queryParameters: [String: String] { [:] }
  public nonisolated var timeoutInterval: TimeInterval { 30 }
}
