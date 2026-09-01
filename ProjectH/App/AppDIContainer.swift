import CoreNetwork
import SharedCommon
import SwiftUI
import UIKit

final class AppDIContainer {
  private lazy var tripStorage: TripStorage = {
    InMemoryTripStorageImpl()
  }()
  
  private lazy var tripRepository: TripRepository = {
    TripRepositoryImpl(
      storage: tripStorage
    )
  }()
  
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
  
  private lazy var reservationRepository: ReservationRepository = {
    AeroDataBoxReservationRepositoryImpl(
      networkService: aeroDataBoxNetworkService
    )
  }()
  
  private lazy var itineraryStorage: ItineraryStorage = {
    InMemoryItineraryStorageImpl()
  }()
  
  private lazy var placeRecommendationRepository: PlaceRecommendationRepository = {
    TravelGuidePlaceRepositoryImpl()
  }()
  
  private lazy var itineraryRepository: ItineraryRepository = {
    ItineraryRepositoryImpl(
      storage: itineraryStorage
    )
  }()
  
  // MARK: - UseCase
  
  private func makeCreateTripUseCase() -> any CreateTripUseCase {
    CreateTripUseCaseImpl(
      reservationRepository: reservationRepository,
      tripRepository: tripRepository
    )
  }
  
  private func makeDeleteTripUseCase() -> any DeleteTripUseCase {
    DeleteTripUseCaseImpl(
      tripRepository: tripRepository
    )
  }
  
  private func makeObserveTripsUseCase() -> any ObserveTripsUseCase {
    ObserveTripsUseCaseImpl(
      tripRepository: tripRepository
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
  
  private func makeDeleteItineraryItemUseCase() -> any DeleteItineraryItemUseCase {
    DeleteItineraryItemUseCaseImpl(
      itineraryRepository: itineraryRepository
    )
  }
  
  private func makeObserveDayPlansUseCase() -> any ObserveDayPlansUseCase {
    ObserveDayPlansUseCaseImpl(
      itineraryRepository: itineraryRepository
    )
  }
}

// MARK: - AppFlowCoordinatorDependencies

extension AppDIContainer: AppFlowCoordinatorDependencies {
  func makeTripListViewController(
    actions: TripListViewModelActions
  ) -> UIViewController {
    TripListViewController(
      viewModel: TripListViewModel(
        actions: actions,
        deleteTripUseCase: makeDeleteTripUseCase(),
        observeTripsUseCase: makeObserveTripsUseCase()
      )
    )
  }
  
  func makeAddReservationViewController(
    actions: AddReservationViewModelActions
  ) -> UIViewController {
    AddReservationViewController(
      viewModel: AddReservationViewModel(
        actions: actions,
        createTripUseCase: makeCreateTripUseCase()
      )
    )
  }
  
  func makeTripCalendarViewController(
    actions: TripCalendarViewModelActions,
    trip: Trip
  ) -> UIViewController {
    TripCalendarViewController(
      viewModel: TripCalendarViewModel(
        actions: actions,
        trip: trip
      )
    )
  }
  
  func makeItineraryViewController(
    trip: Trip
  ) -> UIViewController {
    UIHostingController(
      rootView: ItineraryView(
        viewModel: ItineraryViewModel(
          deleteItineraryItemUseCase: makeDeleteItineraryItemUseCase(),
          observeDayPlansUseCase: makeObserveDayPlansUseCase(),
          recommendAreasUseCase: makeRecommendAreasUseCase(),
          saveItineraryItemUseCase: makeSaveItineraryItemUseCase(),
          trip: trip
        )
      )
    )
  }
}
