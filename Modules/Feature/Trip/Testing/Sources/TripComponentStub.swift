import DomainTripInterface
import FeatureTripInterface
import UIKit

/// Trip 구현체 없이 화면 전환만 확인할 때 꽂는다. 빈 화면을 돌려주고 호출만 기록한다.
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
