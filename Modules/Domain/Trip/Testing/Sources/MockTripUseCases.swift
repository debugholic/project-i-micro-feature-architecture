import DomainTripInterface

/// UseCase가 추상이 된 덕분에 ViewModel 테스트는 Repository까지 내려가지 않고
/// 바로 UseCase를 갈아끼운다.

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
