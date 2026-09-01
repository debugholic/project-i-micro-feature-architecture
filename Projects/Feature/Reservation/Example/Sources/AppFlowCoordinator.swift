import FeatureReservationInterface
import UIKit

@MainActor
protocol AppFlowCoordinatorDependencies {
  func makeAddReservationViewController(
    actions: AddReservationViewModelActions
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
    let actions = AddReservationViewModelActions(
      didFinish: { [weak self] in self?.showFinished() }
    )
    navigationController.setViewControllers(
      [dependencies.makeAddReservationViewController(actions: actions)],
      animated: false
    )
  }

  private func showFinished() {
    let alert = UIAlertController(
      title: "여행이 만들어졌어요",
      message: "앱에서는 이 시점에 목록으로 돌아갑니다.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    navigationController.present(alert, animated: true)
  }
}
