import Combine
import CoreStorage
import DataTrip
import DomainTrip
import DomainTripInterface
import DomainTripTesting
import FeatureTrip
import FeatureTripInterface
import UIKit

@MainActor
final class AppComponent {
  private lazy var tripStorage: any Storage<Trip> = {
    InMemoryStorageImpl(
      elements: [TripFixtures.trip()]
    )
  }()

  private lazy var tripRepository: TripRepository = {
    TripRepositoryImpl(
      storage: tripStorage
    )
  }()

  private lazy var tripComponent: any TripComponent = {
    TripComponentImpl(
      deleteTripUseCase: makeDeleteTripUseCase(),
      trips: tripStorage.elementsPublisher
    )
  }()

  private func makeDeleteTripUseCase() -> any DeleteTripUseCase {
    DeleteTripUseCaseImpl(
      tripRepository: tripRepository
    )
  }
}

// MARK: - AppFlowCoordinatorDependencies

extension AppComponent: AppFlowCoordinatorDependencies {
  func makeTripListViewController(
    actions: TripListViewModelActions
  ) -> UIViewController {
    tripComponent.makeTripListViewController(
      actions: actions
    )
  }

  func makeTripCalendarViewController(
    actions: TripCalendarViewModelActions,
    trip: Trip
  ) -> UIViewController {
    tripComponent.makeTripCalendarViewController(
      actions: actions,
      trip: trip
    )
  }
}
