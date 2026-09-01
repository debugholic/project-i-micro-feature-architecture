import Combine
import Foundation
@testable import ProjectH

/// UseCase가 추상이 된 덕분에 ViewModel 테스트는 Repository까지 내려가지 않고
/// 바로 UseCase를 갈아끼운다.

final class MockCreateTripUseCase: CreateTripUseCase {
  var error: Error?
  private(set) var receivedRequests: [CreateTripRequest] = []

  func execute(request: CreateTripRequest) async throws {
    receivedRequests.append(request)
    if let error { throw error }
  }
}

final class MockDeleteTripUseCase: DeleteTripUseCase {
  private(set) var deletedTrips: [Trip] = []

  func execute(request: Trip) {
    deletedTrips.append(request)
  }
}

final class MockObserveTripsUseCase: ObserveTripsUseCase {
  private let subject = CurrentValueSubject<[Trip], Never>([])

  func emit(_ trips: [Trip]) {
    subject.send(trips)
  }

  func execute(request: Void) -> AnyPublisher<[Trip], Never> {
    subject.eraseToAnyPublisher()
  }
}

final class MockSaveItineraryItemUseCase: SaveItineraryItemUseCase {
  private let subject = PassthroughSubject<ItineraryItem, Never>()

  private(set) var savedItems: [ItineraryItem] = []

  var savedPublisher: AnyPublisher<ItineraryItem, Never> { subject.eraseToAnyPublisher() }

  func execute(request: ItineraryItem) {
    savedItems.append(request)
    subject.send(request)
  }
}

final class MockDeleteItineraryItemUseCase: DeleteItineraryItemUseCase {
  private let subject = PassthroughSubject<ItineraryItem, Never>()

  private(set) var deletedItems: [ItineraryItem] = []

  var deletedPublisher: AnyPublisher<ItineraryItem, Never> { subject.eraseToAnyPublisher() }

  func execute(request: ItineraryItem) {
    deletedItems.append(request)
    subject.send(request)
  }
}

final class MockObserveDayPlansUseCase: ObserveDayPlansUseCase {
  private let subject = CurrentValueSubject<[DayPlan], Never>([])

  private(set) var receivedTrips: [Trip] = []

  func emit(_ plans: [DayPlan]) {
    subject.send(plans)
  }

  func execute(request: Trip) -> AnyPublisher<[DayPlan], Never> {
    receivedTrips.append(request)
    return subject.eraseToAnyPublisher()
  }
}

final class MockRecommendAreasUseCase: RecommendAreasUseCase {
  var areas: [RecommendedArea] = []

  private(set) var receivedCities: [String] = []

  func execute(request city: String) -> [RecommendedArea] {
    receivedCities.append(city)
    return areas
  }
}

