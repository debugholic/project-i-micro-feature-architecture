import CoreStorage
import DataTrip
import DomainReservationInterface
import DomainReservationTesting
import DomainTrip
import DomainTripInterface
import FeatureReservation
import FeatureReservationInterface
import UIKit

@MainActor
final class AppComponent {
  private lazy var reservationRepository: ReservationRepository = {
    let repository = MockReservationRepository()
    repository.stub(
      "KE705",
      with: .success(ReservationFixtures.flightLeg())
    )
    return repository
  }()

  private lazy var tripRepository: TripRepository = {
    TripRepositoryImpl(
      storage: InMemoryStorageImpl<Trip>()
    )
  }()

  private lazy var reservationComponent: any ReservationComponent = {
    ReservationComponentImpl(
      createTripUseCase: makeCreateTripUseCase()
    )
  }()

  private func makeCreateTripUseCase() -> any CreateTripUseCase {
    CreateTripUseCaseImpl(
      reservationRepository: reservationRepository,
      tripRepository: tripRepository
    )
  }
}

// MARK: - AppFlowCoordinatorDependencies

extension AppComponent: AppFlowCoordinatorDependencies {
  func makeAddReservationViewController(
    actions: AddReservationViewModelActions
  ) -> UIViewController {
    reservationComponent.makeAddReservationViewController(
      actions: actions
    )
  }
}
