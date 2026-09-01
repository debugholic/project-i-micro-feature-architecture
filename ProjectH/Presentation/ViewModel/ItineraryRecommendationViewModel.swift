import Combine
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
  private let deleteItineraryItemUseCase: any DeleteItineraryItemUseCase
  private let saveItineraryItemUseCase: any SaveItineraryItemUseCase
  private let tripID: UUID
  private var picked: [String: ItineraryItem]

  init(
    actions: ItineraryRecommendationViewModelActions,
    city: String,
    date: Date,
    deleteItineraryItemUseCase: any DeleteItineraryItemUseCase,
    recommendAreasUseCase: any RecommendAreasUseCase,
    saveItineraryItemUseCase: any SaveItineraryItemUseCase,
    sights: [ItineraryItem],
    tripID: UUID
  ) {
    self.actions = actions
    self.city = city
    self.date = date
    self.deleteItineraryItemUseCase = deleteItineraryItemUseCase
    self.saveItineraryItemUseCase = saveItineraryItemUseCase
    self.tripID = tripID
    self.picked = Dictionary(sights.map { ($0.title, $0) }, uniquingKeysWith: { first, _ in first })
    self.pickedNames = Set(sights.map(\.title))

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
      Task { [deleteItineraryItemUseCase] in
        try? await deleteItineraryItemUseCase.execute(request: existing)
      }
      return
    }

    let item = ItineraryItem(
      category: .sight,
      startTime: date,
      title: place.name,
      tripID: tripID
    )
    picked[place.name] = item
    pickedNames.insert(place.name)
    Task { [saveItineraryItemUseCase] in
      try? await saveItineraryItemUseCase.execute(request: item)
    }
  }
}
