import DomainTripInterface
import FeatureTripInterface
import UIKit

@MainActor
public final class TripComponentStub: TripComponent {
  public private(set) var calendarTrips: [Trip] = []
  public private(set) var tripListCallCount = 0

  public init() {}

  public func makeTripListViewController(
    actions: TripListViewModelActions
  ) -> UIViewController {
    tripListCallCount += 1
    return UIViewController()
  }

  public func makeTripCalendarViewController(
    actions: TripCalendarViewModelActions,
    trip: Trip
  ) -> UIViewController {
    calendarTrips.append(trip)
    return UIViewController()
  }
}
