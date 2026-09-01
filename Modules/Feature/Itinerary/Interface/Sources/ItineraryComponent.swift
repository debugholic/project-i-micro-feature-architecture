import DomainTripInterface
import UIKit

@MainActor
public protocol ItineraryComponent {
  func makeItineraryViewController(
    trip: Trip
  ) -> UIViewController
}
