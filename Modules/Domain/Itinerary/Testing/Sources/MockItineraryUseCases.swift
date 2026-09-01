import Combine
import DomainItineraryInterface
import Foundation

public final class MockSaveItineraryItemUseCase: SaveItineraryItemUseCase {
  private let subject = PassthroughSubject<ItineraryItem, Never>()

  public private(set) var savedItems: [ItineraryItem] = []

  public var savedPublisher: AnyPublisher<ItineraryItem, Never> { subject.eraseToAnyPublisher() }

  public init() {}

  public func execute(request: ItineraryItem) {
    savedItems.append(request)
    subject.send(request)
  }
}

public final class MockDeleteItineraryItemUseCase: DeleteItineraryItemUseCase {
  private let subject = PassthroughSubject<ItineraryItem, Never>()

  public private(set) var deletedItems: [ItineraryItem] = []

  public var deletedPublisher: AnyPublisher<ItineraryItem, Never> { subject.eraseToAnyPublisher() }

  public init() {}

  public func execute(request: ItineraryItem) {
    deletedItems.append(request)
    subject.send(request)
  }
}

public final class MockObserveDayPlansUseCase: ObserveDayPlansUseCase {
  private let subject = CurrentValueSubject<[DayPlan], Never>([])

  public private(set) var receivedTripIDs: [UUID] = []

  public init() {}

  public func emit(_ plans: [DayPlan]) {
    subject.send(plans)
  }

  public func execute(request tripID: UUID) -> AnyPublisher<[DayPlan], Never> {
    receivedTripIDs.append(tripID)
    return subject.eraseToAnyPublisher()
  }
}
