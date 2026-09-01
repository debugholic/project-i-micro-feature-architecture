import DomainItineraryInterface
import DomainRecommendationInterface
import DomainReservationInterface
import DomainTripInterface
import FeatureItineraryInterface
import SharedCommon
import SwiftUI
import UIKit

public struct ItineraryComponentImpl: ItineraryComponent {
  private let deleteItineraryItemUseCase: any DeleteItineraryItemUseCase
  private let observeDayPlansUseCase: any ObserveDayPlansUseCase
  private let recommendAreasUseCase: any RecommendAreasUseCase
  private let saveItineraryItemUseCase: any SaveItineraryItemUseCase

  public init(
    deleteItineraryItemUseCase: any DeleteItineraryItemUseCase,
    observeDayPlansUseCase: any ObserveDayPlansUseCase,
    recommendAreasUseCase: any RecommendAreasUseCase,
    saveItineraryItemUseCase: any SaveItineraryItemUseCase
  ) {
    self.deleteItineraryItemUseCase = deleteItineraryItemUseCase
    self.observeDayPlansUseCase = observeDayPlansUseCase
    self.recommendAreasUseCase = recommendAreasUseCase
    self.saveItineraryItemUseCase = saveItineraryItemUseCase
  }

  public func makeItineraryViewController(
    trip: Trip
  ) -> UIViewController {
    UIHostingController(
      rootView: ItineraryView(
        viewModel: ItineraryViewModel(
          deleteItineraryItemUseCase: deleteItineraryItemUseCase,
          observeDayPlansUseCase: observeDayPlansUseCase,
          recommendAreasUseCase: recommendAreasUseCase,
          saveItineraryItemUseCase: saveItineraryItemUseCase,
          trip: trip
        )
      )
    )
  }
}
