import Combine
import DomainTripInterface
import FeatureTripInterface
import UIKit

public struct TripComponentImpl: TripComponent {
  private let deleteTripUseCase: any DeleteTripUseCase
  private let trips: AnyPublisher<[Trip], Never>

  public init(
    deleteTripUseCase: any DeleteTripUseCase,
    trips: AnyPublisher<[Trip], Never>
  ) {
    self.deleteTripUseCase = deleteTripUseCase
    self.trips = trips
  }

  public func makeTripListViewController(
    actions: TripListViewModelActions
  ) -> UIViewController {
    TripListViewController(
      viewModel: TripListViewModel(
        actions: actions,
        deleteTripUseCase: deleteTripUseCase,
        trips: trips
      )
    )
  }

  public func makeTripCalendarViewController(
    actions: TripCalendarViewModelActions,
    trip: Trip
  ) -> UIViewController {
    TripCalendarViewController(
      viewModel: TripCalendarViewModel(
        actions: actions,
        trip: trip
      )
    )
  }
}
