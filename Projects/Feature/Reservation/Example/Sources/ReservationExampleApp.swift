import DomainTripTesting
import FeatureReservation
import FeatureReservationInterface
import SwiftUI
import UIKit

/// FeatureReservation 만 링크해서 항공편 조회 화면을 단독으로 띄운다.
@main
struct ReservationExampleApp: App {
  var body: some Scene {
    WindowGroup {
      AddReservationScreen()
    }
  }
}

private struct AddReservationScreen: UIViewControllerRepresentable {
  func makeUIViewController(
    context: Context
  ) -> UIViewController {
    let component = ReservationComponentImpl(
      createTripUseCase: MockCreateTripUseCase()
    )

    return UINavigationController(
      rootViewController: component.makeAddReservationViewController(
        actions: AddReservationViewModelActions(
          didFinish: {}
        )
      )
    )
  }

  func updateUIViewController(
    _ uiViewController: UIViewController,
    context: Context
  ) {}
}
