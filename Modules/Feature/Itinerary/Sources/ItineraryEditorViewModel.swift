import Combine
import DomainItineraryInterface
import DomainRecommendationInterface
import DomainReservationInterface
import DomainTripInterface
import Foundation
import SharedCommon

struct ItineraryEditorViewModelActions: ViewModelActions {
  let didFinish: () -> Void
}

protocol ItineraryEditorViewModelInput: ViewModelInput {
  func didSelectSight(_ sight: ItineraryItem)
  func didTapCancel()
  func didTapDelete()
  func didTapSave()
  func didTapUnschedule()
}

protocol ItineraryEditorViewModelOutput: ViewModelOutput {
  var canSave: Bool { get }
  var canUnschedule: Bool { get }
  var category: ItineraryCategory { get }
  var endTime: Date { get set }
  var isEditing: Bool { get }
  var isHourAvailable: Bool { get }
  var isRangeValid: Bool { get }
  var location: String { get set }
  var showsLodgingRange: Bool { get }
  var showsTime: Bool { get }
  var startTime: Date { get set }
  var title: String { get set }
  var unscheduledSights: [ItineraryItem] { get }
}

final class ItineraryEditorViewModel: ViewModel, ObservableObject, ItineraryEditorViewModelOutput, Identifiable {
  @Published var endTime: Date
  @Published var location: String
  @Published var startTime: Date
  @Published var title: String

  @Published private(set) var category: ItineraryCategory
  @Published private(set) var pickedSight: ItineraryItem?

  private let editingItemID: UUID?

  let actions: ItineraryEditorViewModelActions?
  let id = UUID()
  let unscheduledSights: [ItineraryItem]

  private let calendar: Calendar
  private let deleteItineraryItemUseCase: any DeleteItineraryItemUseCase
  private let occupiedHours: Set<Int>
  private let saveItineraryItemUseCase: any SaveItineraryItemUseCase
  private let tripID: UUID

  init(
    actions: ItineraryEditorViewModelActions,
    calendar: Calendar = .current,
    category: ItineraryCategory,
    deleteItineraryItemUseCase: any DeleteItineraryItemUseCase,
    editingItemID: UUID? = nil,
    endTime: Date,
    location: String = "",
    occupiedHours: Set<Int> = [],
    saveItineraryItemUseCase: any SaveItineraryItemUseCase,
    startTime: Date,
    title: String = "",
    tripID: UUID,
    unscheduledSights: [ItineraryItem] = []
  ) {
    self.actions = actions
    self.calendar = calendar
    self.category = category
    self.deleteItineraryItemUseCase = deleteItineraryItemUseCase
    self.editingItemID = editingItemID
    self.endTime = endTime
    self.location = location
    self.occupiedHours = occupiedHours
    self.saveItineraryItemUseCase = saveItineraryItemUseCase
    self.startTime = startTime
    self.title = title
    self.tripID = tripID
    self.unscheduledSights = unscheduledSights
  }

  var canSave: Bool {
    !trimmedTitle.isEmpty && isHourAvailable && isRangeValid
  }

  /// 시각이 붙은 장소만 시간표에서 뺄 수 있다.
  var canUnschedule: Bool {
    isEditing && category == .place
  }

  var isEditing: Bool {
    editingItemID != nil
  }

  /// 칩을 골라 이름이 그대로면 그 항목에 시각을 주는 것이고,
  /// 이름을 고쳤으면 새 항목이다.
  private var itemID: UUID {
    if let editingItemID { return editingItemID }
    if let pickedSight, pickedSight.title == trimmedTitle { return pickedSight.id }
    return UUID()
  }

  var isHourAvailable: Bool {
    guard category == .place else { return true }
    return !occupiedHours.contains(calendar.component(.hour, from: startTime))
  }

  var isRangeValid: Bool {
    guard showsLodgingRange else { return true }
    return startTime < endTime
  }

  var showsLodgingRange: Bool {
    category == .lodging
  }

  /// 시각을 고르는 건 장소뿐이다. 식사는 누른 시간대를, 숙소는 체크인·아웃을 쓴다.
  var showsTime: Bool {
    category == .place
  }

  private var trimmedLocation: String {
    location.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private var trimmedTitle: String {
    title.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func makeItem() -> ItineraryItem {
    ItineraryItem(
      category: category,
      endTime: showsLodgingRange ? endTime : nil,
      id: itemID,
      location: showsLodgingRange && !trimmedLocation.isEmpty ? trimmedLocation : nil,
      startTime: startTime,
      title: trimmedTitle,
      tripID: tripID
    )
  }
}

// MARK: - Input

extension ItineraryEditorViewModel: ItineraryEditorViewModelInput {
  func didSelectSight(_ sight: ItineraryItem) {
    pickedSight = sight
    title = sight.title
  }

  func didTapCancel() {
    actions?.didFinish()
  }

  func didTapDelete() {
    guard isEditing else { return }
    let item = makeItem()

    Task { [deleteItineraryItemUseCase] in
      try? await deleteItineraryItemUseCase.execute(request: item)
    }
    actions?.didFinish()
  }

  func didTapSave() {
    guard canSave else { return }
    save(makeItem())
  }

  func didTapUnschedule() {
    guard canUnschedule else { return }
    category = .sight
    save(makeItem())
  }

  private func save(
    _ item: ItineraryItem
  ) {
    Task { [saveItineraryItemUseCase] in
      try? await saveItineraryItemUseCase.execute(request: item)
    }
    actions?.didFinish()
  }
}
