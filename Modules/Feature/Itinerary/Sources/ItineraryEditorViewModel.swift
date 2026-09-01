import DomainItineraryInterface
import Foundation
import SharedCommon

struct ItineraryEditorViewModelActions: ViewModelActions {
  let didFinish: () -> Void
}

enum ItineraryEditorTarget: Hashable {
  case item(mealSlot: MealSlot?)
  case lodging
  case place
}

protocol ItineraryEditorViewModelInput: ViewModelInput {
  func didSelectPlace(_ place: TripPlace)
  func didTapCancel()
  func didTapDelete()
  func didTapSave()
  func didTapUnschedule()
}

protocol ItineraryEditorViewModelOutput: ViewModelOutput {
  var canSave: Bool { get }
  var canUnschedule: Bool { get }
  var endTime: Date { get set }
  var isEditing: Bool { get }
  var isHourAvailable: Bool { get }
  var isRangeValid: Bool { get }
  var location: String { get set }
  var startTime: Date { get set }
  var target: ItineraryEditorTarget { get }
  var title: String { get set }
  var unscheduledPlaces: [TripPlace] { get }
}

typealias ItineraryEditorViewModelType = ItineraryEditorViewModelInput & ItineraryEditorViewModelOutput

final class ItineraryEditorViewModel: ViewModel, ObservableObject, ItineraryEditorViewModelOutput, Identifiable {
  @Published var endTime: Date
  @Published var location: String
  @Published var startTime: Date
  @Published var title: String

  @Published private(set) var pickedPlace: TripPlace?

  let actions: ItineraryEditorViewModelActions?
  let id = UUID()
  let target: ItineraryEditorTarget
  let unscheduledPlaces: [TripPlace]

  private let calendar: Calendar
  private let date: Date
  private let deleteItineraryItemUseCase: any DeleteItineraryItemUseCase
  private let deleteLodgingUseCase: any DeleteLodgingUseCase
  private let deleteTripPlaceUseCase: any DeleteTripPlaceUseCase
  private let editingItem: ItineraryItem?
  private let editingLodging: Lodging?
  private let editingPlace: TripPlace?
  private let occupiedHours: Set<Int>
  private let saveItineraryItemUseCase: any SaveItineraryItemUseCase
  private let saveLodgingUseCase: any SaveLodgingUseCase
  private let saveTripPlaceUseCase: any SaveTripPlaceUseCase
  private let tripID: UUID

  init(
    actions: ItineraryEditorViewModelActions,
    calendar: Calendar = .current,
    date: Date,
    deleteItineraryItemUseCase: any DeleteItineraryItemUseCase,
    deleteLodgingUseCase: any DeleteLodgingUseCase,
    deleteTripPlaceUseCase: any DeleteTripPlaceUseCase,
    editingItem: ItineraryItem? = nil,
    editingLodging: Lodging? = nil,
    editingPlace: TripPlace? = nil,
    endTime: Date,
    location: String = "",
    occupiedHours: Set<Int> = [],
    saveItineraryItemUseCase: any SaveItineraryItemUseCase,
    saveLodgingUseCase: any SaveLodgingUseCase,
    saveTripPlaceUseCase: any SaveTripPlaceUseCase,
    startTime: Date,
    target: ItineraryEditorTarget,
    title: String = "",
    tripID: UUID,
    unscheduledPlaces: [TripPlace] = []
  ) {
    self.actions = actions
    self.calendar = calendar
    self.date = date
    self.deleteItineraryItemUseCase = deleteItineraryItemUseCase
    self.deleteLodgingUseCase = deleteLodgingUseCase
    self.deleteTripPlaceUseCase = deleteTripPlaceUseCase
    self.editingItem = editingItem
    self.editingLodging = editingLodging
    self.editingPlace = editingPlace
    self.endTime = endTime
    self.location = location
    self.occupiedHours = occupiedHours
    self.saveItineraryItemUseCase = saveItineraryItemUseCase
    self.saveLodgingUseCase = saveLodgingUseCase
    self.saveTripPlaceUseCase = saveTripPlaceUseCase
    self.startTime = startTime
    self.target = target
    self.title = title
    self.tripID = tripID
    self.unscheduledPlaces = unscheduledPlaces
  }

  var canSave: Bool {
    !trimmedTitle.isEmpty && isHourAvailable && isRangeValid
  }

  var canUnschedule: Bool {
    editingItem?.placeID != nil
  }

  var isEditing: Bool {
    editingItem != nil || editingLodging != nil || editingPlace != nil
  }

  var isHourAvailable: Bool {
    guard case .item(nil) = target else { return true }
    return !occupiedHours.contains(calendar.component(.hour, from: startTime))
  }

  var isRangeValid: Bool {
    guard target == .lodging else { return true }
    return startTime < endTime
  }

  private var mealSlot: MealSlot? {
    guard case let .item(slot) = target else { return nil }
    return slot
  }

  private var pickedPlaceID: UUID? {
    guard let pickedPlace, pickedPlace.name == trimmedTitle else { return nil }
    return pickedPlace.id
  }

  private var trimmedLocation: String {
    location.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private var trimmedTitle: String {
    title.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func makeItem() -> ItineraryItem {
    ItineraryItem(
      id: editingItem?.id ?? UUID(),
      mealSlot: mealSlot,
      placeID: editingItem?.placeID ?? pickedPlaceID,
      startTime: startTime,
      title: trimmedTitle,
      tripID: tripID
    )
  }

  private func makeLodging() -> Lodging {
    Lodging(
      checkIn: startTime,
      checkOut: endTime,
      id: editingLodging?.id ?? UUID(),
      location: trimmedLocation.isEmpty ? nil : trimmedLocation,
      name: trimmedTitle,
      tripID: tripID
    )
  }

  private func makePlace() -> TripPlace {
    TripPlace(
      category: editingPlace?.category,
      date: date,
      id: editingPlace?.id ?? UUID(),
      name: trimmedTitle,
      tripID: tripID
    )
  }
}

// MARK: - Input

extension ItineraryEditorViewModel: ItineraryEditorViewModelInput {
  func didSelectPlace(
    _ place: TripPlace
  ) {
    pickedPlace = place
    title = place.name
  }

  func didTapCancel() {
    actions?.didFinish()
  }

  func didTapDelete() {
    guard isEditing else { return }

    switch target {
    case .item:
      guard let editingItem else { return }
      finish { [deleteItineraryItemUseCase] in
        try await deleteItineraryItemUseCase.execute(request: editingItem)
      }
    case .lodging:
      guard let editingLodging else { return }
      finish { [deleteLodgingUseCase] in
        try await deleteLodgingUseCase.execute(request: editingLodging)
      }
    case .place:
      guard let editingPlace else { return }
      finish { [deleteTripPlaceUseCase] in
        try await deleteTripPlaceUseCase.execute(request: editingPlace)
      }
    }
  }

  func didTapSave() {
    guard canSave else { return }

    switch target {
    case .item:
      let item = makeItem()
      finish { [saveItineraryItemUseCase] in
        try await saveItineraryItemUseCase.execute(request: item)
      }
    case .lodging:
      let lodging = makeLodging()
      finish { [saveLodgingUseCase] in
        try await saveLodgingUseCase.execute(request: lodging)
      }
    case .place:
      let place = makePlace()
      finish { [saveTripPlaceUseCase] in
        try await saveTripPlaceUseCase.execute(request: place)
      }
    }
  }

  func didTapUnschedule() {
    guard canUnschedule, let editingItem else { return }

    finish { [deleteItineraryItemUseCase] in
      try await deleteItineraryItemUseCase.execute(request: editingItem)
    }
  }

  private func finish(
    _ work: @escaping () async throws -> Void
  ) {
    Task {
      try? await work()
    }
    actions?.didFinish()
  }
}
