import DomainTripInterface
import UIKit

@MainActor
protocol AppFlowCoordinatorDependencies {
  var trip: Trip { get }

  func makeItineraryViewController(
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
    navigationController.setViewControllers(
      [
        dependencies.makeItineraryViewController(
          trip: dependencies.trip
        )
      ],
      animated: false
    )
  }
}
