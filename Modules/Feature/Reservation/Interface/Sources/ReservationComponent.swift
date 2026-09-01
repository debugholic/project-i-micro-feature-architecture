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

/// 항공편 조회 화면을 조립해 내놓는다.
@MainActor
public protocol ReservationComponent {
  func makeAddReservationViewController(
    actions: AddReservationViewModelActions
  ) -> UIViewController
}
