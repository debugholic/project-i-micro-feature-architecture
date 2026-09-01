import DomainTripInterface
import FeatureTripInterface
import UIKit

@MainActor
protocol AppFlowCoordinatorDependencies {
  
  func makeTripListViewController(
    actions: TripListViewModelActions
  ) -> UIViewController
  
  func makeTripCalendarViewController(
    actions: TripCalendarViewModelActions,
    trip: Trip
  ) -> UIViewController
  
}

@MainActor
final class AppFlowCoordinator {
  let navigationController: UINavigationController

  private let dependencies: AppFlowCoordinatorDependencies

  init(
    dependencies: AppFlowCoordinatorDependencies,
    navigationController: UINavigationController
  ) {
    self.dependencies = dependencies
    self.navigationController = navigationController
  }

  func start() {
    let actions = TripListViewModelActions(
      showAddReservation: {},
      showCalendar: { [weak self] trip in self?.showCalendar(trip) }
    )
    navigationController.setViewControllers(
      [dependencies.makeTripListViewController(actions: actions)],
      animated: false
    )
  }

  private func showCalendar(
    _ trip: Trip
  ) {
    let actions = TripCalendarViewModelActions(
      showItinerary: { _ in }
    )
    navigationController.pushViewController(
      dependencies.makeTripCalendarViewController(actions: actions, trip: trip),
      animated: true
    )
  }
}
