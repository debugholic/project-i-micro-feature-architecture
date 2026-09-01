import Combine
import DomainItineraryInterface
import DomainItineraryTesting
import DomainRecommendationInterface
import Foundation
import SharedCommonTesting
import XCTest
@testable import FeatureItinerary

final class ItineraryEditorViewModelTests: XCTestCase {

  private var cancellables = Set<AnyCancellable>()

  override func tearDown() {
    cancellables.removeAll()
    super.tearDown()
  }

  // MARK: - 저장 가능 여부

  func test_canSave_isFalseUntilTitleHasContent() {
    let sut = makeSUT()

    XCTAssertFalse(sut.canSave)

    sut.title = "   "
    XCTAssertFalse(sut.canSave)

    sut.title = "오도리 공원"
    XCTAssertTrue(sut.canSave)
  }

  func test_canSave_isFalseWhenHourIsTaken() {
    let sut = makeSUT(
      occupiedHours: [13],
      startTime: TestDate.moment(day: 15, hour: 13, minute: 30)
    )
    sut.title = "오도리 공원"

    XCTAssertFalse(sut.isHourAvailable)
    XCTAssertFalse(sut.canSave)

    sut.startTime = TestDate.moment(day: 15, hour: 14)
    XCTAssertTrue(sut.canSave)
  }

  func test_meal_ignoresHourCollision() {
    let sut = makeSUT(
      occupiedHours: [9],
      startTime: TestDate.moment(day: 15, hour: 9),
      target: .item(mealSlot: .dinner)
    )
    sut.title = "63 로쿠산"

    XCTAssertTrue(sut.isHourAvailable)
    XCTAssertTrue(sut.canSave)
  }

  func test_place_ignoresOccupiedHours() {
    let sut = makeSUT(occupiedHours: [9], target: .place)
    sut.title = "오도리 공원"

    XCTAssertTrue(sut.isHourAvailable)
    XCTAssertTrue(sut.canSave)
  }

  // MARK: - 시간표 항목

  func test_didTapSave_buildsItemFromForm() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let tripID = UUID()
    let startTime = TestDate.moment(day: 15, hour: 13, minute: 30)
    let sut = makeSUT(
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      startTime: startTime,
      tripID: tripID
    )
    sut.title = "  오도리 공원  "

    let saved = expect(saveItineraryItemUseCase.savedPublisher)
    sut.didTapSave()
    wait(for: [saved.expectation], timeout: 2.0)

    XCTAssertEqual(saved.value?.title, "오도리 공원")
    XCTAssertEqual(saved.value?.startTime, startTime)
    XCTAssertEqual(saved.value?.tripID, tripID)
    XCTAssertNil(saved.value?.mealSlot)
    XCTAssertNil(saved.value?.placeID)
  }

  func test_didTapSave_mealKeepsItsSlot() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let sut = makeSUT(
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      target: .item(mealSlot: .dinner)
    )
    sut.title = "63 로쿠산"

    let saved = expect(saveItineraryItemUseCase.savedPublisher)
    sut.didTapSave()
    wait(for: [saved.expectation], timeout: 2.0)

    XCTAssertEqual(saved.value?.mealSlot, .dinner)
  }

  func test_didTapSave_whenEditing_keepsSameID() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let tripID = UUID()
    let editing = ItineraryFixtures.itineraryItem(title: "오도리 공원", tripID: tripID)
    let sut = makeSUT(
      editingItem: editing,
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      title: editing.title,
      tripID: tripID
    )
    sut.title = "삿포로 TV타워"

    let saved = expect(saveItineraryItemUseCase.savedPublisher)
    sut.didTapSave()
    wait(for: [saved.expectation], timeout: 2.0)

    XCTAssertEqual(saved.value?.id, editing.id)
    XCTAssertEqual(saved.value?.title, "삿포로 TV타워")
  }

  // MARK: - 숙소

  func test_lodging_savesRangeAndLocation() {
    let saveLodgingUseCase = MockSaveLodgingUseCase()
    let checkIn = TestDate.moment(day: 15, hour: 14)
    let checkOut = TestDate.moment(day: 17, hour: 10)
    let sut = makeSUT(
      endTime: checkOut,
      location: "Noboribetsu",
      saveLodgingUseCase: saveLodgingUseCase,
      startTime: checkIn,
      target: .lodging
    )
    sut.title = "다이이치 다키모토칸"

    let saved = expect(saveLodgingUseCase.savedPublisher)
    sut.didTapSave()
    wait(for: [saved.expectation], timeout: 2.0)

    XCTAssertEqual(saved.value?.checkIn, checkIn)
    XCTAssertEqual(saved.value?.checkOut, checkOut)
    XCTAssertEqual(saved.value?.location, "Noboribetsu")
  }

  func test_lodging_checkOutBeforeCheckIn_cannotSave() {
    let sut = makeSUT(
      endTime: TestDate.moment(day: 15, hour: 10),
      startTime: TestDate.moment(day: 15, hour: 14),
      target: .lodging
    )
    sut.title = "다이이치 다키모토칸"

    XCTAssertFalse(sut.isRangeValid)
    XCTAssertFalse(sut.canSave)
  }

  // MARK: - 담아둔 곳

  func test_place_savesWithoutTime() {
    let saveTripPlaceUseCase = MockSaveTripPlaceUseCase()
    let date = TestDate.moment(day: 15)
    let tripID = UUID()
    let sut = makeSUT(
      date: date,
      saveTripPlaceUseCase: saveTripPlaceUseCase,
      target: .place,
      tripID: tripID
    )
    sut.title = "다누키코지 상점가"

    let saved = expect(saveTripPlaceUseCase.savedPublisher)
    sut.didTapSave()
    wait(for: [saved.expectation], timeout: 2.0)

    XCTAssertEqual(saved.value?.name, "다누키코지 상점가")
    XCTAssertEqual(saved.value?.date, date)
    XCTAssertEqual(saved.value?.tripID, tripID)
    XCTAssertNil(saved.value?.category)
  }

  func test_place_whenEditing_keepsCategory() {
    let saveTripPlaceUseCase = MockSaveTripPlaceUseCase()
    let tripID = UUID()
    let editing = ItineraryFixtures.place(category: .food, name: "에비소바 이치겐", tripID: tripID)
    let sut = makeSUT(
      editingPlace: editing,
      saveTripPlaceUseCase: saveTripPlaceUseCase,
      target: .place,
      title: editing.name,
      tripID: tripID
    )
    sut.title = "에비소바 이치겐 본점"

    let saved = expect(saveTripPlaceUseCase.savedPublisher)
    sut.didTapSave()
    wait(for: [saved.expectation], timeout: 2.0)

    XCTAssertEqual(saved.value?.id, editing.id)
    XCTAssertEqual(saved.value?.category, .food)
  }

  // MARK: - 담아둔 곳을 시간표로

  func test_didSelectPlace_linksItemToThatPlace() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let tripID = UUID()
    let place = ItineraryFixtures.place(name: "오도리 공원", tripID: tripID)
    let sut = makeSUT(
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      tripID: tripID,
      unscheduledPlaces: [place]
    )

    sut.didSelectPlace(place)
    XCTAssertEqual(sut.title, "오도리 공원")

    let saved = expect(saveItineraryItemUseCase.savedPublisher)
    sut.didTapSave()
    wait(for: [saved.expectation], timeout: 2.0)

    XCTAssertEqual(saved.value?.placeID, place.id)
  }

  func test_didSelectPlace_thenRenaming_createsUnlinkedItem() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let tripID = UUID()
    let place = ItineraryFixtures.place(name: "오도리 공원", tripID: tripID)
    let sut = makeSUT(
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      tripID: tripID,
      unscheduledPlaces: [place]
    )

    sut.didSelectPlace(place)
    sut.title = "삿포로 TV타워"

    let saved = expect(saveItineraryItemUseCase.savedPublisher)
    sut.didTapSave()
    wait(for: [saved.expectation], timeout: 2.0)

    XCTAssertNil(saved.value?.placeID)
    XCTAssertEqual(saved.value?.title, "삿포로 TV타워")
  }

  func test_didSelectPlace_thenPickingAnother_bindsToTheLastOne() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let tripID = UUID()
    let first = ItineraryFixtures.place(name: "오도리 공원", tripID: tripID)
    let second = ItineraryFixtures.place(name: "다누키코지 상점가", tripID: tripID)
    let sut = makeSUT(
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      tripID: tripID,
      unscheduledPlaces: [first, second]
    )

    sut.didSelectPlace(first)
    sut.didSelectPlace(second)

    let saved = expect(saveItineraryItemUseCase.savedPublisher)
    sut.didTapSave()
    wait(for: [saved.expectation], timeout: 2.0)

    XCTAssertEqual(saved.value?.placeID, second.id)
  }

  // MARK: - 시간표에서 빼기

  func test_didTapUnschedule_deletesItemAndKeepsPlace() {
    let deleteItineraryItemUseCase = MockDeleteItineraryItemUseCase()
    let deleteTripPlaceUseCase = MockDeleteTripPlaceUseCase()
    let tripID = UUID()
    let place = ItineraryFixtures.place(tripID: tripID)
    let editing = ItineraryFixtures.itineraryItem(placeID: place.id, tripID: tripID)
    let sut = makeSUT(
      deleteItineraryItemUseCase: deleteItineraryItemUseCase,
      deleteTripPlaceUseCase: deleteTripPlaceUseCase,
      editingItem: editing,
      title: editing.title,
      tripID: tripID
    )

    XCTAssertTrue(sut.canUnschedule)

    let deleted = expect(deleteItineraryItemUseCase.deletedPublisher)
    sut.didTapUnschedule()
    wait(for: [deleted.expectation], timeout: 2.0)

    XCTAssertEqual(deleted.value?.id, editing.id)
    XCTAssertTrue(deleteTripPlaceUseCase.deletedPlaces.isEmpty)
  }

  func test_canUnschedule_isFalseWhenItemHasNoPlace() {
    let tripID = UUID()

    XCTAssertFalse(makeSUT(tripID: tripID).canUnschedule)
    XCTAssertFalse(
      makeSUT(
        editingItem: ItineraryFixtures.itineraryItem(tripID: tripID),
        tripID: tripID
      ).canUnschedule
    )
  }

  // MARK: - 삭제 · 취소

  func test_didTapDelete_whenEditing_deletesAndFinishes() {
    let deleteItineraryItemUseCase = MockDeleteItineraryItemUseCase()
    let tripID = UUID()
    let editing = ItineraryFixtures.itineraryItem(tripID: tripID)
    var didFinish = false
    let sut = makeSUT(
      deleteItineraryItemUseCase: deleteItineraryItemUseCase,
      didFinish: { didFinish = true },
      editingItem: editing,
      tripID: tripID
    )

    let deleted = expect(deleteItineraryItemUseCase.deletedPublisher)
    sut.didTapDelete()
    wait(for: [deleted.expectation], timeout: 2.0)

    XCTAssertEqual(deleted.value?.id, editing.id)
    XCTAssertTrue(didFinish)
  }

  func test_didTapDelete_whenCreating_doesNothing() {
    let deleteItineraryItemUseCase = MockDeleteItineraryItemUseCase()
    var didFinish = false
    let sut = makeSUT(
      deleteItineraryItemUseCase: deleteItineraryItemUseCase,
      didFinish: { didFinish = true }
    )

    sut.didTapDelete()

    XCTAssertTrue(deleteItineraryItemUseCase.deletedItems.isEmpty)
    XCTAssertFalse(didFinish)
  }

  func test_didTapSave_withBlankTitle_doesNothing() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    var didFinish = false
    let sut = makeSUT(
      didFinish: { didFinish = true },
      saveItineraryItemUseCase: saveItineraryItemUseCase
    )
    sut.title = "   "

    sut.didTapSave()

    XCTAssertTrue(saveItineraryItemUseCase.savedItems.isEmpty)
    XCTAssertFalse(didFinish)
  }

  func test_didTapCancel_finishesWithoutSaving() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    var didFinish = false
    let sut = makeSUT(
      didFinish: { didFinish = true },
      saveItineraryItemUseCase: saveItineraryItemUseCase
    )
    sut.title = "오도리 공원"

    sut.didTapCancel()

    XCTAssertTrue(saveItineraryItemUseCase.savedItems.isEmpty)
    XCTAssertTrue(didFinish)
  }

  // MARK: - Helpers

  private final class Received<Value> {
    let expectation: XCTestExpectation
    var value: Value?

    init(expectation: XCTestExpectation) {
      self.expectation = expectation
    }
  }

  private func expect<Value>(
    _ publisher: AnyPublisher<Value, Never>
  ) -> Received<Value> {
    let received = Received<Value>(expectation: expectation(description: "\(Value.self)"))
    publisher
      .sink { [received] value in
        received.value = value
        received.expectation.fulfill()
      }
      .store(in: &cancellables)
    return received
  }

  private func makeSUT(
    date: Date = TestDate.moment(day: 15),
    deleteItineraryItemUseCase: MockDeleteItineraryItemUseCase = MockDeleteItineraryItemUseCase(),
    deleteLodgingUseCase: MockDeleteLodgingUseCase = MockDeleteLodgingUseCase(),
    deleteTripPlaceUseCase: MockDeleteTripPlaceUseCase = MockDeleteTripPlaceUseCase(),
    didFinish: @escaping () -> Void = {},
    editingItem: ItineraryItem? = nil,
    editingLodging: Lodging? = nil,
    editingPlace: TripPlace? = nil,
    endTime: Date = TestDate.moment(day: 16, hour: 11),
    location: String = "",
    occupiedHours: Set<Int> = [],
    saveItineraryItemUseCase: MockSaveItineraryItemUseCase = MockSaveItineraryItemUseCase(),
    saveLodgingUseCase: MockSaveLodgingUseCase = MockSaveLodgingUseCase(),
    saveTripPlaceUseCase: MockSaveTripPlaceUseCase = MockSaveTripPlaceUseCase(),
    startTime: Date = TestDate.moment(day: 15, hour: 9),
    target: ItineraryEditorTarget = .item(mealSlot: nil),
    title: String = "",
    tripID: UUID = UUID(),
    unscheduledPlaces: [TripPlace] = []
  ) -> ItineraryEditorViewModel {
    ItineraryEditorViewModel(
      actions: ItineraryEditorViewModelActions(didFinish: didFinish),
      date: date,
      deleteItineraryItemUseCase: deleteItineraryItemUseCase,
      deleteLodgingUseCase: deleteLodgingUseCase,
      deleteTripPlaceUseCase: deleteTripPlaceUseCase,
      editingItem: editingItem,
      editingLodging: editingLodging,
      editingPlace: editingPlace,
      endTime: endTime,
      location: location,
      occupiedHours: occupiedHours,
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      saveLodgingUseCase: saveLodgingUseCase,
      saveTripPlaceUseCase: saveTripPlaceUseCase,
      startTime: startTime,
      target: target,
      title: title,
      tripID: tripID,
      unscheduledPlaces: unscheduledPlaces
    )
  }
}
