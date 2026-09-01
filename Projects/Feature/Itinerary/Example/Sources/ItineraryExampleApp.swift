import DomainItineraryInterface
import DomainItineraryTesting
import DomainRecommendationTesting
import DomainTripTesting
import FeatureItinerary
import FeatureItineraryInterface
import Foundation
import SharedCommonTesting
import SwiftUI
import UIKit

/// FeatureItinerary 만 링크해서 일정 화면을 단독으로 띄운다.
@main
struct ItineraryExampleApp: App {
  var body: some Scene {
    WindowGroup {
      ItineraryScreen()
    }
  }
}

private struct ItineraryScreen: UIViewControllerRepresentable {
  func makeUIViewController(
    context: Context
  ) -> UIViewController {
    let calendar = Calendar.current
    let observeDayPlansUseCase = MockObserveDayPlansUseCase()
    observeDayPlansUseCase.emit(
      (15...16).map { day in
        ItineraryFixtures.dayPlan(
          date: calendar.startOfDay(
            for: TestDate.moment(day: day)
          )
        )
      }
    )

    let component = ItineraryComponentImpl(
      deleteItineraryItemUseCase: MockDeleteItineraryItemUseCase(),
      observeDayPlansUseCase: observeDayPlansUseCase,
      recommendAreasUseCase: MockRecommendAreasUseCase(),
      saveItineraryItemUseCase: MockSaveItineraryItemUseCase()
    )

    return UINavigationController(
      rootViewController: component.makeItineraryViewController(
        trip: TripFixtures.trip()
      )
    )
  }

  func updateUIViewController(
    _ uiViewController: UIViewController,
    context: Context
  ) {}
}
