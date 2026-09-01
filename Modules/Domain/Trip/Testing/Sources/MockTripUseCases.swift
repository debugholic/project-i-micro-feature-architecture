import DomainTripInterface


public final class MockCreateTripUseCase: CreateTripUseCase {
  public var error: Error?
  public private(set) var receivedRequests: [CreateTripRequest] = []

  public init() {}

  public func execute(request: CreateTripRequest) async throws {
    receivedRequests.append(request)
    if let error { throw error }
  }
}

public final class MockDeleteTripUseCase: DeleteTripUseCase {
  public private(set) var deletedTrips: [Trip] = []

  public init() {}

  public func execute(request: Trip) {
    deletedTrips.append(request)
  }
}
