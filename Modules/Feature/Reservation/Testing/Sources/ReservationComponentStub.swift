import FeatureReservationInterface
import UIKit

/// Reservation 구현체 없이 화면 전환만 확인할 때 꽂는다.
@MainActor
public final class ReservationComponentStub: ReservationComponent {
  public private(set) var callCount = 0

  public init() {}

  public func makeAddReservationViewController(
    actions: AddReservationViewModelActions
  ) -> UIViewController {
    callCount += 1
    return UIViewController()
  }
}
