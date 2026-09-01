import Combine
import DomainTripInterface
import DomainTripTesting
import FeatureTrip
import FeatureTripInterface
import SwiftUI
import UIKit

/// FeatureTrip 만 링크해서 여행 목록 화면을 단독으로 띄운다.
@main
struct TripExampleApp: App {
  var body: some Scene {
    WindowGroup {
      TripListScreen()
    }
  }
}

private struct TripListScreen: UIViewControllerRepresentable {
  func makeUIViewController(
    context: Context
  ) -> UIViewController {
    let component = TripComponentImpl(
      deleteTripUseCase: MockDeleteTripUseCase(),
      trips: CurrentValueSubject<[Trip], Never>(
        [TripFixtures.trip()]
      ).eraseToAnyPublisher()
    )

    return UINavigationController(
      rootViewController: component.makeTripListViewController(
        actions: TripListViewModelActions(
          showAddReservation: {},
          showCalendar: { _ in }
        )
      )
    )
  }

  func updateUIViewController(
    _ uiViewController: UIViewController,
    context: Context
  ) {}
}
