import DomainTripInterface
import UIKit

/// 일정 화면을 조립해 내놓는다.
@MainActor
public protocol ItineraryComponent {
  func makeItineraryViewController(
    trip: Trip
  ) -> UIViewController
}
