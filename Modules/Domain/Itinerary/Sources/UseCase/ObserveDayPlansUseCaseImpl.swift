import Combine
import DomainItineraryInterface
import DomainTripInterface
import Foundation

public struct ObserveDayPlansUseCaseImpl: ObserveDayPlansUseCase {
  private let builder: DayPlanBuilder
  private let items: AnyPublisher<[ItineraryItem], Never>
  private let lodgings: AnyPublisher<[Lodging], Never>
  private let places: AnyPublisher<[TripPlace], Never>
  private let trips: AnyPublisher<[Trip], Never>

  public init(
    calendar: Calendar = .current,
    items: AnyPublisher<[ItineraryItem], Never>,
    lodgings: AnyPublisher<[Lodging], Never>,
    places: AnyPublisher<[TripPlace], Never>,
    trips: AnyPublisher<[Trip], Never>
  ) {
    self.builder = DayPlanBuilder(calendar: calendar)
    self.items = items
    self.lodgings = lodgings
    self.places = places
    self.trips = trips
  }

  public func execute(
    request tripID: UUID
  ) -> AnyPublisher<[DayPlan], Never> {
    Publishers.CombineLatest4(trips, items, lodgings, places)
      .compactMap { trips, items, lodgings, places -> [DayPlan]? in
        guard let trip = trips.first(where: { $0.id == tripID }) else { return nil }
        return builder.build(
          trip: trip,
          items: items.filter { $0.tripID == tripID },
          lodgings: lodgings.filter { $0.tripID == tripID },
          places: places.filter { $0.tripID == tripID }
        )
      }
      .eraseToAnyPublisher()
  }
}
