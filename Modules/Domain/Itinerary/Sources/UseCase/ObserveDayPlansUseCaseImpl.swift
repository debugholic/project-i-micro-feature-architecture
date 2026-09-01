import Combine
import DomainItineraryInterface
import DomainTripInterface
import Foundation

public struct ObserveDayPlansUseCaseImpl: ObserveDayPlansUseCase {
  private let builder: DayPlanBuilder
  private let items: AnyPublisher<[ItineraryItem], Never>
  private let trips: AnyPublisher<[Trip], Never>

  public init(
    calendar: Calendar = .current,
    items: AnyPublisher<[ItineraryItem], Never>,
    trips: AnyPublisher<[Trip], Never>
  ) {
    self.builder = DayPlanBuilder(calendar: calendar)
    self.items = items
    self.trips = trips
  }

  public func execute(
    request tripID: UUID
  ) -> AnyPublisher<[DayPlan], Never> {
    Publishers.CombineLatest(trips, items)
      .compactMap { trips, items -> [DayPlan]? in
        guard let trip = trips.first(where: { $0.id == tripID }) else { return nil }
        return builder.build(
          trip: trip,
          items: items.filter { $0.tripID == tripID }
        )
      }
      .eraseToAnyPublisher()
  }
}
