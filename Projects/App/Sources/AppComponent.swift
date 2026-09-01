import CoreNetwork
import CoreStorage
import DataItinerary
import DataRecommendation
import DataReservation
import DataTrip
import DomainItinerary
import DomainItineraryInterface
import DomainRecommendation
import DomainRecommendationInterface
import DomainReservationInterface
import DomainTrip
import DomainTripInterface
import FeatureItinerary
import FeatureItineraryInterface
import FeatureReservation
import FeatureReservationInterface
import FeatureTrip
import FeatureTripInterface
import Foundation
import SharedCommon
import UIKit

/// 모듈을 조립한다. 화면 전환은 `AppFlowCoordinator` 가 맡는다.
@MainActor
final class AppComponent {
  // MARK: - Storage

  private lazy var itineraryStorage: any Storage<ItineraryItem> = {
    UserDefaultsStorageImpl(
      key: "itineraryItems"
    )
  }()

  private lazy var tripStorage: any Storage<Trip> = {
    UserDefaultsStorageImpl(
      key: "trips"
    )
  }()

  // MARK: - Network

  private let aeroDataBoxHost = "aerodatabox.p.rapidapi.com"
  private let apiKey = AppConfig.rapidAPIKey

  private lazy var aeroDataBoxAPIConfig: NetworkConfigurable = {
    APIConfig(
      baseURL: URL(
        string: "https://\(aeroDataBoxHost)"
      ),
      headers: [
        "X-RapidAPI-Host": aeroDataBoxHost,
        "X-RapidAPI-Key": apiKey,
      ]
    )
  }()

  private lazy var aeroDataBoxNetworkService: NetworkService = {
    NetworkServiceImpl(
      config: aeroDataBoxAPIConfig
    )
  }()

  // MARK: - Repository

  private lazy var itineraryRepository: ItineraryRepository = {
    ItineraryRepositoryImpl(
      storage: itineraryStorage
    )
  }()

  private lazy var placeRecommendationRepository: PlaceRecommendationRepository = {
    TravelGuidePlaceRepositoryImpl()
  }()

  private lazy var reservationRepository: ReservationRepository = {
    AeroDataBoxReservationRepositoryImpl(
      networkService: aeroDataBoxNetworkService
    )
  }()

  private lazy var tripRepository: TripRepository = {
    TripRepositoryImpl(
      storage: tripStorage
    )
  }()

  // MARK: - Component

  private lazy var itineraryComponent: any ItineraryComponent = {
    ItineraryComponentImpl(
      deleteItineraryItemUseCase: makeDeleteItineraryItemUseCase(),
      observeDayPlansUseCase: makeObserveDayPlansUseCase(),
      recommendAreasUseCase: makeRecommendAreasUseCase(),
      saveItineraryItemUseCase: makeSaveItineraryItemUseCase()
    )
  }()

  private lazy var reservationComponent: any ReservationComponent = {
    ReservationComponentImpl(
      createTripUseCase: makeCreateTripUseCase()
    )
  }()

  private lazy var tripComponent: any TripComponent = {
    TripComponentImpl(
      deleteTripUseCase: makeDeleteTripUseCase(),
      trips: tripStorage.elementsPublisher
    )
  }()

  // MARK: - UseCase

  private func makeCreateTripUseCase() -> any CreateTripUseCase {
    CreateTripUseCaseImpl(
      reservationRepository: reservationRepository,
      tripRepository: tripRepository
    )
  }

  private func makeDeleteItineraryItemUseCase() -> any DeleteItineraryItemUseCase {
    DeleteItineraryItemUseCaseImpl(
      itineraryRepository: itineraryRepository
    )
  }

  private func makeDeleteTripUseCase() -> any DeleteTripUseCase {
    DeleteTripUseCaseImpl(
      tripRepository: tripRepository
    )
  }

  private func makeObserveDayPlansUseCase() -> any ObserveDayPlansUseCase {
    ObserveDayPlansUseCaseImpl(
      items: itineraryStorage.elementsPublisher,
      trips: tripStorage.elementsPublisher
    )
  }

  private func makeRecommendAreasUseCase() -> any RecommendAreasUseCase {
    RecommendAreasUseCaseImpl(
      placeRecommendationRepository: placeRecommendationRepository
    )
  }

  private func makeSaveItineraryItemUseCase() -> any SaveItineraryItemUseCase {
    SaveItineraryItemUseCaseImpl(
      itineraryRepository: itineraryRepository
    )
  }
}

// MARK: - AppFlowCoordinatorDependencies

extension AppComponent: AppFlowCoordinatorDependencies {
  func makeTripListViewController(
    actions: TripListViewModelActions
  ) -> UIViewController {
    tripComponent.makeTripListViewController(
      actions: actions
    )
  }

  func makeAddReservationViewController(
    actions: AddReservationViewModelActions
  ) -> UIViewController {
    reservationComponent.makeAddReservationViewController(
      actions: actions
    )
  }

  func makeTripCalendarViewController(
    actions: TripCalendarViewModelActions,
    trip: Trip
  ) -> UIViewController {
    tripComponent.makeTripCalendarViewController(
      actions: actions,
      trip: trip
    )
  }

  func makeItineraryViewController(
    trip: Trip
  ) -> UIViewController {
    itineraryComponent.makeItineraryViewController(
      trip: trip
    )
  }
}
