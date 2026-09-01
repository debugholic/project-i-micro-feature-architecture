import DomainTripInterface
import SharedCommon
import UIKit

public struct TripListViewModelActions: ViewModelActions {
  public let showAddReservation: () -> Void
  public let showCalendar: (Trip) -> Void

  public init(
    showAddReservation: @escaping () -> Void,
    showCalendar: @escaping (Trip) -> Void
  ) {
    self.showAddReservation = showAddReservation
    self.showCalendar = showCalendar
  }
}

public struct TripCalendarViewModelActions: ViewModelActions {
  public let showItinerary: (Trip) -> Void

  public init(
    showItinerary: @escaping (Trip) -> Void
  ) {
    self.showItinerary = showItinerary
  }
}

@MainActor
public protocol TripComponent {
  func makeTripListViewController(
    actions: TripListViewModelActions
  ) -> UIViewController

  func makeTripCalendarViewController(
    actions: TripCalendarViewModelActions,
    trip: Trip
  ) -> UIViewController
}
