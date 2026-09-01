import Combine
import DomainItineraryInterface
import DomainRecommendationInterface
import DomainTripInterface
import Foundation
import SharedCommon

protocol ItineraryViewModelInput: ViewModelInput {
  func didDismissEditor()
  func didDismissRecommendations()
  func didSelectDate(_ date: Date)
  func didSelectItem(_ item: ItineraryItem)
  func didSelectLodging()
  func didSelectPlace(_ place: TripPlace)
  func didTapAddSight()
  func didTapCreateSight()
  func didTapHour(_ hour: Int)
  func didTapMeal(_ slot: MealSlot)
}

protocol ItineraryViewModelOutput: ViewModelOutput {
  var dayPlans: [DayPlan] { get }
  var editorViewModel: ItineraryEditorViewModel? { get }
  var firstItemHour: Int? { get }
  var recommendationViewModel: ItineraryRecommendationViewModel? { get }
  var selectedDate: Date? { get }
  var selectedPlan: DayPlan? { get }
  var trip: Trip { get }

  func hour(of item: DayPlanItem) -> Int
}

typealias ItineraryViewModelType = ItineraryViewModelInput & ItineraryViewModelOutput

final class ItineraryViewModel: ViewModel, ObservableObject, ItineraryViewModelOutput {
  @Published private(set) var dayPlans: [DayPlan] = []
  @Published private(set) var editorViewModel: ItineraryEditorViewModel?
  @Published private(set) var recommendationViewModel: ItineraryRecommendationViewModel?
  @Published private(set) var selectedDate: Date?

  let trip: Trip

  private let calendar: Calendar
  private let deleteItineraryItemUseCase: any DeleteItineraryItemUseCase
  private let deleteLodgingUseCase: any DeleteLodgingUseCase
  private let deleteTripPlaceUseCase: any DeleteTripPlaceUseCase
  private let recommendAreasUseCase: any RecommendAreasUseCase
  private let saveItineraryItemUseCase: any SaveItineraryItemUseCase
  private let saveLodgingUseCase: any SaveLodgingUseCase
  private let saveTripPlaceUseCase: any SaveTripPlaceUseCase
  private var cancellables = Set<AnyCancellable>()

  init(
    calendar: Calendar = .current,
    deleteItineraryItemUseCase: any DeleteItineraryItemUseCase,
    deleteLodgingUseCase: any DeleteLodgingUseCase,
    deleteTripPlaceUseCase: any DeleteTripPlaceUseCase,
    observeDayPlansUseCase: any ObserveDayPlansUseCase,
    recommendAreasUseCase: any RecommendAreasUseCase,
    saveItineraryItemUseCase: any SaveItineraryItemUseCase,
    saveLodgingUseCase: any SaveLodgingUseCase,
    saveTripPlaceUseCase: any SaveTripPlaceUseCase,
    trip: Trip
  ) {
    self.calendar = calendar
    self.deleteItineraryItemUseCase = deleteItineraryItemUseCase
    self.deleteLodgingUseCase = deleteLodgingUseCase
    self.deleteTripPlaceUseCase = deleteTripPlaceUseCase
    self.recommendAreasUseCase = recommendAreasUseCase
    self.saveItineraryItemUseCase = saveItineraryItemUseCase
    self.saveLodgingUseCase = saveLodgingUseCase
    self.saveTripPlaceUseCase = saveTripPlaceUseCase
    self.trip = trip

    Task { [weak self] in
      guard let self,
            let plans = try? await observeDayPlansUseCase.execute(request: trip.id)
      else { return }

      plans
        .receive(on: DispatchQueue.main)
        .sink { [weak self] plans in self?.apply(plans) }
        .store(in: &self.cancellables)
    }
  }

  var firstItemHour: Int? {
    selectedPlan?.timelineItems.first.map(hour(of:))
  }

  var selectedPlan: DayPlan? {
    dayPlans.first { $0.date == selectedDate }
  }

  func hour(of item: DayPlanItem) -> Int {
    calendar.component(.hour, from: item.startTime)
  }

  private var defaultLodgingLocation: String {
    selectedPlan.map { ItineraryFormatter.placeName($0.destination) } ?? ""
  }

  private var unscheduledPlaces: [TripPlace] {
    guard let selectedPlan else { return [] }
    return selectedPlan.places.filter { selectedPlan.item(for: $0) == nil }
  }

  private func defaultCheckOut(after startTime: Date) -> Date {
    let nextDay = calendar.date(byAdding: .day, value: 1, to: startTime) ?? startTime
    return calendar.date(
      bySettingHour: ItineraryDefaultHour.checkOut,
      minute: 0,
      second: 0,
      of: nextDay
    ) ?? nextDay
  }

  private func occupiedHours(excluding item: ItineraryItem?) -> Set<Int> {
    let items = (selectedPlan?.timelineItems ?? []).filter { $0.itineraryItem?.id != item?.id }
    return Set(items.map(hour(of:)))
  }

  private func apply(_ plans: [DayPlan]) {
    dayPlans = plans
    guard let selectedDate, plans.contains(where: { $0.date == selectedDate }) else {
      self.selectedDate = plans.first?.date
      return
    }
  }

  private func openEditor(
    target: ItineraryEditorTarget,
    editingItem: ItineraryItem? = nil,
    editingLodging: Lodging? = nil,
    editingPlace: TripPlace? = nil,
    hour: Int
  ) {
    guard let selectedDate,
          let startTime = editingItem?.startTime
            ?? editingLodging?.checkIn
            ?? calendar.date(bySettingHour: hour, minute: 0, second: 0, of: selectedDate)
    else { return }

    let isCreating = editingItem == nil && editingLodging == nil && editingPlace == nil

    editorViewModel = ItineraryEditorViewModel(
      actions: ItineraryEditorViewModelActions(
        didFinish: { [weak self] in self?.editorViewModel = nil }
      ),
      calendar: calendar,
      date: selectedDate,
      deleteItineraryItemUseCase: deleteItineraryItemUseCase,
      deleteLodgingUseCase: deleteLodgingUseCase,
      deleteTripPlaceUseCase: deleteTripPlaceUseCase,
      editingItem: editingItem,
      editingLodging: editingLodging,
      editingPlace: editingPlace,
      endTime: editingLodging?.checkOut ?? defaultCheckOut(after: startTime),
      location: editingLodging?.location ?? (target == .lodging ? defaultLodgingLocation : ""),
      occupiedHours: occupiedHours(excluding: editingItem),
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      saveLodgingUseCase: saveLodgingUseCase,
      saveTripPlaceUseCase: saveTripPlaceUseCase,
      startTime: startTime,
      target: target,
      title: editingItem?.title ?? editingLodging?.name ?? editingPlace?.name ?? "",
      tripID: trip.id,
      unscheduledPlaces: isCreating ? unscheduledPlaces : []
    )
  }
}

// MARK: - Input

extension ItineraryViewModel: ItineraryViewModelInput {
  func didDismissEditor() {
    editorViewModel = nil
  }

  func didDismissRecommendations() {
    recommendationViewModel = nil
  }

  func didSelectDate(_ date: Date) {
    selectedDate = date
  }

  func didSelectItem(_ item: ItineraryItem) {
    openEditor(
      target: .item(mealSlot: item.mealSlot),
      editingItem: item,
      hour: calendar.component(.hour, from: item.startTime)
    )
  }

  func didSelectLodging() {
    openEditor(
      target: .lodging,
      editingLodging: selectedPlan?.lodging,
      hour: ItineraryDefaultHour.checkIn
    )
  }

  func didSelectPlace(_ place: TripPlace) {
    guard let item = selectedPlan?.item(for: place) else {
      openEditor(target: .place, editingPlace: place, hour: ItineraryDefaultHour.sight)
      return
    }
    didSelectItem(item)
  }

  func didTapAddSight() {
    guard let selectedDate, let destination = selectedPlan?.destination else { return }

    recommendationViewModel = ItineraryRecommendationViewModel(
      actions: ItineraryRecommendationViewModelActions(
        didFinish: { [weak self] in self?.recommendationViewModel = nil }
      ),
      city: ItineraryFormatter.placeName(destination),
      date: selectedDate,
      deleteTripPlaceUseCase: deleteTripPlaceUseCase,
      places: selectedPlan?.places ?? [],
      recommendAreasUseCase: recommendAreasUseCase,
      saveTripPlaceUseCase: saveTripPlaceUseCase,
      tripID: trip.id
    )
  }

  func didTapCreateSight() {
    openEditor(target: .place, hour: ItineraryDefaultHour.sight)
  }

  func didTapHour(_ hour: Int) {
    guard !occupiedHours(excluding: nil).contains(hour) else { return }
    openEditor(target: .item(mealSlot: nil), hour: hour)
  }

  func didTapMeal(_ slot: MealSlot) {
    openEditor(
      target: .item(mealSlot: slot),
      editingItem: selectedPlan?.meal(slot),
      hour: 0
    )
  }
}
