import DomainTripInterface
import FeatureItineraryInterface
import UIKit

@MainActor
public final class ItineraryComponentStub: ItineraryComponent {
  public private(set) var trips: [Trip] = []

  public init() {}

  public func makeItineraryViewController(
    trip: Trip
  ) -> UIViewController {
    trips.append(trip)
    return UIViewController()
  }
}
