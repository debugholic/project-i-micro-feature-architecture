import Combine
import DomainItineraryInterface
import DomainRecommendationInterface
import DomainReservationInterface
import DomainTripInterface
import Foundation
import SharedCommon

struct ItineraryRecommendationViewModelActions: ViewModelActions {
  let didFinish: () -> Void
}

protocol ItineraryRecommendationViewModelInput: ViewModelInput {
  func didTapClose()
  func didTapPlace(_ place: RecommendedPlace)
}

protocol ItineraryRecommendationViewModelOutput: ViewModelOutput {
  var areas: [RecommendedArea] { get }
  var city: String { get }
  var isLoading: Bool { get }
  var pickedNames: Set<String> { get }
}

final class ItineraryRecommendationViewModel: ViewModel, ObservableObject, ItineraryRecommendationViewModelOutput, Identifiable {
  @Published private(set) var areas: [RecommendedArea] = []
  @Published private(set) var isLoading = true
  @Published private(set) var pickedNames: Set<String>

  let actions: ItineraryRecommendationViewModelActions?
  let city: String
  let id = UUID()

  private let date: Date
  private let deleteTripPlaceUseCase: any DeleteTripPlaceUseCase
  private let saveTripPlaceUseCase: any SaveTripPlaceUseCase
  private let tripID: UUID
  private var picked: [String: TripPlace]

  init(
    actions: ItineraryRecommendationViewModelActions,
    city: String,
    date: Date,
    deleteTripPlaceUseCase: any DeleteTripPlaceUseCase,
    places: [TripPlace],
    recommendAreasUseCase: any RecommendAreasUseCase,
    saveTripPlaceUseCase: any SaveTripPlaceUseCase,
    tripID: UUID
  ) {
    self.actions = actions
    self.city = city
    self.date = date
    self.deleteTripPlaceUseCase = deleteTripPlaceUseCase
    self.saveTripPlaceUseCase = saveTripPlaceUseCase
    self.tripID = tripID
    self.picked = Dictionary(places.map { ($0.name, $0) }, uniquingKeysWith: { first, _ in first })
    self.pickedNames = Set(places.map(\.name))

    Task { [weak self] in
      let loaded = (try? await recommendAreasUseCase.execute(request: city)) ?? []
      await self?.apply(loaded)
    }
  }

  @MainActor
  private func apply(_ areas: [RecommendedArea]) {
    self.areas = areas
    isLoading = false
  }
}

// MARK: - Input

extension ItineraryRecommendationViewModel: ItineraryRecommendationViewModelInput {
  func didTapClose() {
    actions?.didFinish()
  }

  func didTapPlace(
    _ place: RecommendedPlace
  ) {
    if let existing = picked[place.name] {
      picked[place.name] = nil
      pickedNames.remove(place.name)
      Task { [deleteTripPlaceUseCase] in
        try? await deleteTripPlaceUseCase.execute(request: existing)
      }
      return
    }

    let picking = TripPlace(
      category: place.category,
      date: date,
      name: place.name,
      tripID: tripID
    )
    picked[place.name] = picking
    pickedNames.insert(place.name)
    Task { [saveTripPlaceUseCase] in
      try? await saveTripPlaceUseCase.execute(request: picking)
    }
  }
}
