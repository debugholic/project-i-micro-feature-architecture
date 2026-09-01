import FeatureReservationInterface
import UIKit

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
