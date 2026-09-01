import DomainItineraryInterface
import DomainRecommendationInterface
import DomainTripInterface
import FeatureItineraryInterface
import SwiftUI
import UIKit

public struct ItineraryComponentImpl: ItineraryComponent {
  private let deleteItineraryItemUseCase: any DeleteItineraryItemUseCase
  private let deleteLodgingUseCase: any DeleteLodgingUseCase
  private let deleteTripPlaceUseCase: any DeleteTripPlaceUseCase
  private let observeDayPlansUseCase: any ObserveDayPlansUseCase
  private let recommendAreasUseCase: any RecommendAreasUseCase
  private let saveItineraryItemUseCase: any SaveItineraryItemUseCase
  private let saveLodgingUseCase: any SaveLodgingUseCase
  private let saveTripPlaceUseCase: any SaveTripPlaceUseCase

  public init(
    deleteItineraryItemUseCase: any DeleteItineraryItemUseCase,
    deleteLodgingUseCase: any DeleteLodgingUseCase,
    deleteTripPlaceUseCase: any DeleteTripPlaceUseCase,
    observeDayPlansUseCase: any ObserveDayPlansUseCase,
    recommendAreasUseCase: any RecommendAreasUseCase,
    saveItineraryItemUseCase: any SaveItineraryItemUseCase,
    saveLodgingUseCase: any SaveLodgingUseCase,
    saveTripPlaceUseCase: any SaveTripPlaceUseCase
  ) {
    self.deleteItineraryItemUseCase = deleteItineraryItemUseCase
    self.deleteLodgingUseCase = deleteLodgingUseCase
    self.deleteTripPlaceUseCase = deleteTripPlaceUseCase
    self.observeDayPlansUseCase = observeDayPlansUseCase
    self.recommendAreasUseCase = recommendAreasUseCase
    self.saveItineraryItemUseCase = saveItineraryItemUseCase
    self.saveLodgingUseCase = saveLodgingUseCase
    self.saveTripPlaceUseCase = saveTripPlaceUseCase
  }

  public func makeItineraryViewController(
    trip: Trip
  ) -> UIViewController {
    UIHostingController(
      rootView: ItineraryView(
        viewModel: ItineraryViewModel(
          deleteItineraryItemUseCase: deleteItineraryItemUseCase,
          deleteLodgingUseCase: deleteLodgingUseCase,
          deleteTripPlaceUseCase: deleteTripPlaceUseCase,
          observeDayPlansUseCase: observeDayPlansUseCase,
          recommendAreasUseCase: recommendAreasUseCase,
          saveItineraryItemUseCase: saveItineraryItemUseCase,
          saveLodgingUseCase: saveLodgingUseCase,
          saveTripPlaceUseCase: saveTripPlaceUseCase,
          trip: trip
        )
      )
    )
  }
}
