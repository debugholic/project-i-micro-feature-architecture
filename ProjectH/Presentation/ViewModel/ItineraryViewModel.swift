import Combine
import Foundation
import SharedCommon

protocol ItineraryViewModelInput: ViewModelInput {
  func didDismissEditor()
  func didDismissRecommendations()
  func didSelectDate(_ date: Date)
  func didSelectItem(_ item: ItineraryItem)
  func didTapAddSight()
  func didTapHour(_ hour: Int)
  func didTapLodging()
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
  private let recommendAreasUseCase: any RecommendAreasUseCase
  private let saveItineraryItemUseCase: any SaveItineraryItemUseCase
  private var cancellables = Set<AnyCancellable>()

  init(
    calendar: Calendar = .current,
    deleteItineraryItemUseCase: any DeleteItineraryItemUseCase,
    observeDayPlansUseCase: any ObserveDayPlansUseCase,
    recommendAreasUseCase: any RecommendAreasUseCase,
    saveItineraryItemUseCase: any SaveItineraryItemUseCase,
    trip: Trip
  ) {
    self.calendar = calendar
    self.deleteItineraryItemUseCase = deleteItineraryItemUseCase
    self.recommendAreasUseCase = recommendAreasUseCase
    self.saveItineraryItemUseCase = saveItineraryItemUseCase
    self.trip = trip

    Task { [weak self] in
      guard let self,
            let plans = try? await observeDayPlansUseCase.execute(request: trip)
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

  private func defaultLocation(for category: ItineraryCategory) -> String {
    guard category == .lodging, let destination = selectedPlan?.destination else { return "" }
    return ItineraryFormatter.placeName(destination)
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

  private var unscheduledSights: [ItineraryItem] {
    (selectedPlan?.sights ?? []).filter { $0.category == .sight }
  }

  private func openEditor(
    category: ItineraryCategory,
    editingItem: ItineraryItem? = nil,
    hour: Int
  ) {
    guard let selectedDate,
          let startTime = editingItem?.startTime
            ?? calendar.date(bySettingHour: hour, minute: 0, second: 0, of: selectedDate)
    else { return }

    let endTime = editingItem?.endTime ?? defaultCheckOut(after: startTime)

    editorViewModel = ItineraryEditorViewModel(
      actions: ItineraryEditorViewModelActions(
        didFinish: { [weak self] in self?.editorViewModel = nil }
      ),
      calendar: calendar,
      category: category,
      deleteItineraryItemUseCase: deleteItineraryItemUseCase,
      editingItemID: editingItem?.id,
      endTime: endTime,
      hasTime: editingItem.map { $0.category != .sight } ?? true,
      location: editingItem?.location ?? defaultLocation(for: category),
      occupiedHours: occupiedHours(excluding: editingItem),
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      startTime: startTime,
      title: editingItem?.title ?? "",
      tripID: trip.id,
      unscheduledSights: editingItem == nil ? unscheduledSights : []
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

  func didTapAddSight() {
    guard let selectedDate, let destination = selectedPlan?.destination else { return }

    recommendationViewModel = ItineraryRecommendationViewModel(
      actions: ItineraryRecommendationViewModelActions(
        didFinish: { [weak self] in self?.recommendationViewModel = nil }
      ),
      city: ItineraryFormatter.placeName(destination),
      date: selectedDate,
      deleteItineraryItemUseCase: deleteItineraryItemUseCase,
      recommendAreasUseCase: recommendAreasUseCase,
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      sights: unscheduledSights,
      tripID: trip.id
    )
  }

  func didSelectDate(_ date: Date) {
    selectedDate = date
  }

  func didSelectItem(_ item: ItineraryItem) {
    openEditor(
      category: item.category,
      editingItem: item,
      hour: calendar.component(.hour, from: item.startTime)
    )
  }

  func didTapHour(_ hour: Int) {
    guard !occupiedHours(excluding: nil).contains(hour) else { return }
    openEditor(category: .place, hour: hour)
  }

  func didTapLodging() {
    openEditor(
      category: .lodging,
      editingItem: selectedPlan?.lodging,
      hour: ItineraryDefaultHour.checkIn
    )
  }

  func didTapMeal(_ slot: MealSlot) {
    openEditor(
      category: .meal(slot),
      editingItem: selectedPlan?.meal(slot),
      hour: 0
    )
  }
}
