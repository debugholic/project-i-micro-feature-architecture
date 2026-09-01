import CoreStorage
import DataItinerary
import DataRecommendation
import DomainItinerary
import DomainItineraryInterface
import DomainRecommendation
import DomainRecommendationInterface
import DomainTripInterface
import DomainTripTesting
import FeatureItinerary
import FeatureItineraryInterface
import UIKit

@MainActor
final class AppComponent {
  let trip = TripFixtures.trip()

  private lazy var itineraryStorage: any Storage<ItineraryItem> = {
    InMemoryStorageImpl()
  }()

  private lazy var lodgingStorage: any Storage<Lodging> = {
    InMemoryStorageImpl()
  }()

  private lazy var tripPlaceStorage: any Storage<TripPlace> = {
    InMemoryStorageImpl()
  }()

  private lazy var tripStorage: any Storage<Trip> = {
    InMemoryStorageImpl(elements: [trip])
  }()

  private lazy var itineraryRepository: ItineraryRepository = {
    ItineraryRepositoryImpl(storage: itineraryStorage)
  }()

  private lazy var lodgingRepository: LodgingRepository = {
    LodgingRepositoryImpl(storage: lodgingStorage)
  }()

  private lazy var placeRecommendationRepository: PlaceRecommendationRepository = {
    TravelGuidePlaceRepositoryImpl()
  }()

  private lazy var tripPlaceRepository: TripPlaceRepository = {
    TripPlaceRepositoryImpl(storage: tripPlaceStorage)
  }()

  private lazy var itineraryComponent: any ItineraryComponent = {
    ItineraryComponentImpl(
      deleteItineraryItemUseCase: DeleteItineraryItemUseCaseImpl(
        itineraryRepository: itineraryRepository
      ),
      deleteLodgingUseCase: DeleteLodgingUseCaseImpl(
        lodgingRepository: lodgingRepository
      ),
      deleteTripPlaceUseCase: DeleteTripPlaceUseCaseImpl(
        tripPlaceRepository: tripPlaceRepository
      ),
      observeDayPlansUseCase: ObserveDayPlansUseCaseImpl(
        items: itineraryStorage.elementsPublisher,
        lodgings: lodgingStorage.elementsPublisher,
        places: tripPlaceStorage.elementsPublisher,
        trips: tripStorage.elementsPublisher
      ),
      recommendAreasUseCase: RecommendAreasUseCaseImpl(
        placeRecommendationRepository: placeRecommendationRepository
      ),
      saveItineraryItemUseCase: SaveItineraryItemUseCaseImpl(
        itineraryRepository: itineraryRepository
      ),
      saveLodgingUseCase: SaveLodgingUseCaseImpl(
        lodgingRepository: lodgingRepository
      ),
      saveTripPlaceUseCase: SaveTripPlaceUseCaseImpl(
        tripPlaceRepository: tripPlaceRepository
      )
    )
  }()
}

// MARK: - AppFlowCoordinatorDependencies

extension AppComponent: AppFlowCoordinatorDependencies {
  func makeItineraryViewController(
    trip: Trip
  ) -> UIViewController {
    itineraryComponent.makeItineraryViewController(
      trip: trip
    )
  }
}
