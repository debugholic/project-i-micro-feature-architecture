import SharedCommon
import UIKit

public struct AddReservationViewModelActions: ViewModelActions {
  public let didFinish: () -> Void

  public init(
    didFinish: @escaping () -> Void
  ) {
    self.didFinish = didFinish
  }
}

@MainActor
public protocol ReservationComponent {
  func makeAddReservationViewController(
    actions: AddReservationViewModelActions
  ) -> UIViewController
}
