import DomainTripInterface
import FeatureReservationInterface
import UIKit

public struct ReservationComponentImpl: ReservationComponent {
  private let createTripUseCase: any CreateTripUseCase

  public init(
    createTripUseCase: any CreateTripUseCase
  ) {
    self.createTripUseCase = createTripUseCase
  }

  public func makeAddReservationViewController(
    actions: AddReservationViewModelActions
  ) -> UIViewController {
    AddReservationViewController(
      viewModel: AddReservationViewModel(
        actions: actions,
        createTripUseCase: createTripUseCase
      )
    )
  }
}
