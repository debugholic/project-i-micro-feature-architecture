import Combine
import DomainTripInterface
import FeatureTripInterface
import Foundation
import SharedCommon

protocol TripListViewModelInput: ViewModelInput {
  func didTapAddReservation()
  func didSelectTrip(_ trip: Trip)
  func didDeleteTrip(_ trip: Trip)
}

protocol TripListViewModelOutput: ViewModelOutput {
  var trips: [Trip] { get }
  var tripsPublisher: AnyPublisher<[Trip], Never> { get }
}

typealias TripListViewModelType = TripListViewModelInput & TripListViewModelOutput

final class TripListViewModel: ViewModel, TripListViewModelOutput {
  @Published private(set) var trips: [Trip] = []
  var tripsPublisher: AnyPublisher<[Trip], Never> { $trips.eraseToAnyPublisher() }

  private let deleteTripUseCase: any DeleteTripUseCase
  let actions: TripListViewModelActions?
  private var cancellables = Set<AnyCancellable>()

  init(
    actions: TripListViewModelActions,
    deleteTripUseCase: any DeleteTripUseCase,
    trips: AnyPublisher<[Trip], Never>
  ) {
    self.deleteTripUseCase = deleteTripUseCase
    self.actions = actions

    trips
      .receive(on: DispatchQueue.main)
      .sink { [weak self] trips in self?.trips = trips }
      .store(in: &cancellables)
  }
}

// MARK: - Input

extension TripListViewModel: TripListViewModelInput {
  func didTapAddReservation() {
    actions?.showAddReservation()
  }

  func didSelectTrip(_ trip: Trip) {
    actions?.showCalendar(trip)
  }

  func didDeleteTrip(_ trip: Trip) {
    Task { [weak self] in
      try? await self?.deleteTripUseCase.execute(request: trip)
    }
  }
}
