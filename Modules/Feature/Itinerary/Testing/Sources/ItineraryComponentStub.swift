import DomainTripInterface
import FeatureItineraryInterface
import UIKit

/// Itinerary 구현체 없이 화면 전환만 확인할 때 꽂는다. Trip Example 이 이걸 쓴다.
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
