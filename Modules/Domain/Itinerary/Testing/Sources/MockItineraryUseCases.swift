import Combine
import DomainItineraryInterface
import Foundation


public final class MockSaveItineraryItemUseCase: SaveItineraryItemUseCase {
  private let subject = PassthroughSubject<ItineraryItem, Never>()

  public private(set) var savedItems: [ItineraryItem] = []

  public var savedPublisher: AnyPublisher<ItineraryItem, Never> {
    subject.eraseToAnyPublisher()
  }

  public init() {}

  public func execute(request item: ItineraryItem) {
    savedItems.append(item)
    subject.send(item)
  }
}

public final class MockDeleteItineraryItemUseCase: DeleteItineraryItemUseCase {
  private let subject = PassthroughSubject<ItineraryItem, Never>()

  public private(set) var deletedItems: [ItineraryItem] = []

  public var deletedPublisher: AnyPublisher<ItineraryItem, Never> {
    subject.eraseToAnyPublisher()
  }

  public init() {}

  public func execute(request item: ItineraryItem) {
    deletedItems.append(item)
    subject.send(item)
  }
}

public final class MockSaveLodgingUseCase: SaveLodgingUseCase {
  private let subject = PassthroughSubject<Lodging, Never>()

  public private(set) var savedLodgings: [Lodging] = []

  public var savedPublisher: AnyPublisher<Lodging, Never> {
    subject.eraseToAnyPublisher()
  }

  public init() {}

  public func execute(request lodging: Lodging) {
    savedLodgings.append(lodging)
    subject.send(lodging)
  }
}

public final class MockDeleteLodgingUseCase: DeleteLodgingUseCase {
  private let subject = PassthroughSubject<Lodging, Never>()

  public private(set) var deletedLodgings: [Lodging] = []

  public var deletedPublisher: AnyPublisher<Lodging, Never> {
    subject.eraseToAnyPublisher()
  }

  public init() {}

  public func execute(request lodging: Lodging) {
    deletedLodgings.append(lodging)
    subject.send(lodging)
  }
}

public final class MockSaveTripPlaceUseCase: SaveTripPlaceUseCase {
  private let subject = PassthroughSubject<TripPlace, Never>()

  public private(set) var savedPlaces: [TripPlace] = []

  public var savedPublisher: AnyPublisher<TripPlace, Never> {
    subject.eraseToAnyPublisher()
  }

  public init() {}

  public func execute(request place: TripPlace) {
    savedPlaces.append(place)
    subject.send(place)
  }
}

public final class MockDeleteTripPlaceUseCase: DeleteTripPlaceUseCase {
  private let subject = PassthroughSubject<TripPlace, Never>()

  public private(set) var deletedPlaces: [TripPlace] = []

  public var deletedPublisher: AnyPublisher<TripPlace, Never> {
    subject.eraseToAnyPublisher()
  }

  public init() {}

  public func execute(request place: TripPlace) {
    deletedPlaces.append(place)
    subject.send(place)
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
