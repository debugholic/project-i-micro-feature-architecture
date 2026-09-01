public protocol UseCase<Request, Response> {
  associatedtype Request
  associatedtype Response

  @discardableResult
  func execute(request: Request) async throws -> Response
}

extension UseCase where Request == Void {
  @discardableResult
  public func execute() async throws -> Response {
    try await execute(request: ())
  }
}
