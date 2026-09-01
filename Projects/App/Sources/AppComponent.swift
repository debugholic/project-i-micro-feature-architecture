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

@MainActor
final class AppComponent {
  // MARK: - Storage

  private lazy var itineraryStorage: any Storage<ItineraryItem> = {
    UserDefaultsStorageImpl(
      key: "itineraryItems"
    )
  }()

  private lazy var lodgingStorage: any Storage<Lodging> = {
    UserDefaultsStorageImpl(
      key: "lodgings"
    )
  }()

  private lazy var tripPlaceStorage: any Storage<TripPlace> = {
    UserDefaultsStorageImpl(
      key: "tripPlaces"
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

  private lazy var lodgingRepository: LodgingRepository = {
    LodgingRepositoryImpl(
      storage: lodgingStorage
    )
  }()

  private lazy var tripPlaceRepository: TripPlaceRepository = {
    TripPlaceRepositoryImpl(
      storage: tripPlaceStorage
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
      deleteLodgingUseCase: makeDeleteLodgingUseCase(),
      deleteTripPlaceUseCase: makeDeleteTripPlaceUseCase(),
      observeDayPlansUseCase: makeObserveDayPlansUseCase(),
      recommendAreasUseCase: makeRecommendAreasUseCase(),
      saveItineraryItemUseCase: makeSaveItineraryItemUseCase(),
      saveLodgingUseCase: makeSaveLodgingUseCase(),
      saveTripPlaceUseCase: makeSaveTripPlaceUseCase()
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

  private func makeDeleteLodgingUseCase() -> any DeleteLodgingUseCase {
    DeleteLodgingUseCaseImpl(
      lodgingRepository: lodgingRepository
    )
  }

  private func makeDeleteTripPlaceUseCase() -> any DeleteTripPlaceUseCase {
    DeleteTripPlaceUseCaseImpl(
      tripPlaceRepository: tripPlaceRepository
    )
  }

  private func makeObserveDayPlansUseCase() -> any ObserveDayPlansUseCase {
    ObserveDayPlansUseCaseImpl(
      items: itineraryStorage.elementsPublisher,
      lodgings: lodgingStorage.elementsPublisher,
      places: tripPlaceStorage.elementsPublisher,
      trips: tripStorage.elementsPublisher
    )
  }

  private func makeSaveLodgingUseCase() -> any SaveLodgingUseCase {
    SaveLodgingUseCaseImpl(
      lodgingRepository: lodgingRepository
    )
  }

  private func makeSaveTripPlaceUseCase() -> any SaveTripPlaceUseCase {
    SaveTripPlaceUseCaseImpl(
      tripPlaceRepository: tripPlaceRepository
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
