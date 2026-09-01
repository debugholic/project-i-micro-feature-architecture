import Combine
import DomainItineraryInterface
import DomainItineraryTesting
import DomainRecommendationInterface
import DomainRecommendationTesting
import DomainReservationInterface
import DomainReservationTesting
import DomainTripInterface
import DomainTripTesting
import Foundation
import SharedCommon
import SharedCommonTesting
import XCTest
@testable import FeatureItinerary


final class ItineraryEditorViewModelTests: XCTestCase {

  private var cancellables = Set<AnyCancellable>()

  override func tearDown() {
    cancellables.removeAll()
    super.tearDown()
  }

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

  func test_lodging_savesRangeAndLocation() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let checkIn = TestDate.moment(day: 15, hour: 14)
    let checkOut = TestDate.moment(day: 17, hour: 10)
    let sut = makeSUT(
      category: .lodging,
      endTime: checkOut,
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      startTime: checkIn
    )
    sut.location = "  Noboribetsu  "
    sut.title = "다이이치 타키모토칸"

    let saved = expectation(description: "저장 전달")
    var receivedItem: ItineraryItem?
    saveItineraryItemUseCase.savedPublisher
      .sink { receivedItem = $0; saved.fulfill() }
      .store(in: &cancellables)

    sut.didTapSave()

    wait(for: [saved], timeout: 2.0)
    XCTAssertTrue(sut.showsLodgingRange)
    XCTAssertFalse(sut.showsTime)
    XCTAssertEqual(receivedItem?.startTime, checkIn)
    XCTAssertEqual(receivedItem?.endTime, checkOut)
    XCTAssertEqual(receivedItem?.location, "Noboribetsu")
  }

  func test_lodging_checkOutBeforeCheckIn_cannotSave() {
    let sut = makeSUT(
      category: .lodging,
      endTime: TestDate.moment(day: 15, hour: 10),
      startTime: TestDate.moment(day: 15, hour: 15)
    )
    sut.title = "베셀 호텔"

    XCTAssertFalse(sut.isRangeValid)
    XCTAssertFalse(sut.canSave)

    sut.endTime = TestDate.moment(day: 16, hour: 11)
    XCTAssertTrue(sut.canSave)
  }

  func test_meal_ignoresTimeEntirely() {
    let sut = makeSUT(
      category: .meal(.dinner),
      occupiedHours: [9],
      startTime: TestDate.moment(day: 15, hour: 9)
    )
    sut.title = "63 로쿠산"

    XCTAssertFalse(sut.showsTime)
    XCTAssertTrue(sut.isHourAvailable)
    XCTAssertTrue(sut.canSave)
  }

  func test_didTapSave_buildsItemFromForm() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let tripID = UUID()
    var didFinish = false
    let sut = makeSUT(
      category: .meal(.dinner),
      didFinish: { didFinish = true },
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      tripID: tripID
    )
    sut.title = "  63 로쿠산  "

    let saved = expectation(description: "저장 전달")
    var receivedItem: ItineraryItem?
    saveItineraryItemUseCase.savedPublisher
      .sink { receivedItem = $0; saved.fulfill() }
      .store(in: &cancellables)

    sut.didTapSave()

    wait(for: [saved], timeout: 2.0)
    XCTAssertEqual(receivedItem?.category, .meal(.dinner))
    XCTAssertEqual(receivedItem?.title, "63 로쿠산")
    XCTAssertEqual(receivedItem?.tripID, tripID)
    XCTAssertTrue(didFinish)
  }

  func test_didTapSave_whenEditing_keepsSameID() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let editingItemID = UUID()
    let sut = makeSUT(
      editingItemID: editingItemID,
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      title: "오도리 공원"
    )
    sut.title = "삿포로 TV타워"

    let saved = expectation(description: "저장 전달")
    var receivedItem: ItineraryItem?
    saveItineraryItemUseCase.savedPublisher
      .sink { receivedItem = $0; saved.fulfill() }
      .store(in: &cancellables)

    sut.didTapSave()

    wait(for: [saved], timeout: 2.0)
    XCTAssertTrue(sut.isEditing)
    XCTAssertEqual(receivedItem?.id, editingItemID)
    XCTAssertEqual(receivedItem?.title, "삿포로 TV타워")
  }

  func test_didTapDelete_whenEditing_deletesAndFinishes() {
    let deleteItineraryItemUseCase = MockDeleteItineraryItemUseCase()
    let editingItemID = UUID()
    var didFinish = false
    let sut = makeSUT(
      deleteItineraryItemUseCase: deleteItineraryItemUseCase,
      didFinish: { didFinish = true },
      editingItemID: editingItemID,
      title: "오도리 공원"
    )

    let deleted = expectation(description: "삭제 전달")
    var receivedItem: ItineraryItem?
    deleteItineraryItemUseCase.deletedPublisher
      .sink { receivedItem = $0; deleted.fulfill() }
      .store(in: &cancellables)

    sut.didTapDelete()

    wait(for: [deleted], timeout: 2.0)
    XCTAssertEqual(receivedItem?.id, editingItemID)
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

    XCTAssertFalse(sut.isEditing)
    XCTAssertEqual(deleteItineraryItemUseCase.deletedItems, [])
    XCTAssertFalse(didFinish)
  }

  func test_didTapSave_withBlankTitle_doesNothing() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    var didFinish = false
    let sut = makeSUT(
      didFinish: { didFinish = true },
      saveItineraryItemUseCase: saveItineraryItemUseCase
    )

    sut.didTapSave()

    XCTAssertEqual(saveItineraryItemUseCase.savedItems, [])
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

    XCTAssertEqual(saveItineraryItemUseCase.savedItems, [])
    XCTAssertTrue(didFinish)
  }

  func test_sight_hasNoTimeFieldAndStaysSight() {
    let sut = makeSUT(category: .sight)
    sut.title = "오도리 공원"

    XCTAssertEqual(sut.category, .sight)
    XCTAssertFalse(sut.showsTime)
    XCTAssertTrue(sut.canSave)
  }

  func test_place_showsTimeField() {
    let sut = makeSUT(category: .place)
    sut.title = "오도리 공원"

    XCTAssertEqual(sut.category, .place)
    XCTAssertTrue(sut.showsTime)
  }

  func test_didSelectSight_promotesSameItem() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let tripID = UUID()
    let sight = ItineraryFixtures.itineraryItem(category: .sight, title: "오도리 공원", tripID: tripID)
    let sut = makeSUT(
      category: .place,
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      startTime: TestDate.moment(day: 15, hour: 13),
      tripID: tripID,
      unscheduledSights: [sight]
    )

    sut.didSelectSight(sight)

    XCTAssertEqual(sut.title, "오도리 공원")

    let saved = expectation(description: "저장 전달")
    var receivedItem: ItineraryItem?
    saveItineraryItemUseCase.savedPublisher
      .sink { receivedItem = $0; saved.fulfill() }
      .store(in: &cancellables)

    sut.didTapSave()

    wait(for: [saved], timeout: 2.0)
    XCTAssertEqual(receivedItem?.id, sight.id)
    XCTAssertEqual(receivedItem?.category, .place)
    XCTAssertEqual(receivedItem?.startTime, TestDate.moment(day: 15, hour: 13))
  }

  func test_didSelectSight_thenRenaming_createsNewItemInstead() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let tripID = UUID()
    let sight = ItineraryFixtures.itineraryItem(category: .sight, title: "오도리 공원", tripID: tripID)
    let sut = makeSUT(
      category: .place,
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      tripID: tripID,
      unscheduledSights: [sight]
    )

    sut.didSelectSight(sight)
    sut.title = "삿포로 시계탑"

    let saved = expectation(description: "저장 전달")
    var receivedItem: ItineraryItem?
    saveItineraryItemUseCase.savedPublisher
      .sink { receivedItem = $0; saved.fulfill() }
      .store(in: &cancellables)

    sut.didTapSave()

    wait(for: [saved], timeout: 2.0)
    XCTAssertNotEqual(receivedItem?.id, sight.id)
    XCTAssertEqual(receivedItem?.title, "삿포로 시계탑")
  }

  func test_didSelectSight_thenPickingAnother_bindsToTheLastOne() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let tripID = UUID()
    let first = ItineraryFixtures.itineraryItem(category: .sight, title: "오도리 공원", tripID: tripID)
    let second = ItineraryFixtures.itineraryItem(category: .sight, title: "삿포로 TV타워", tripID: tripID)
    let sut = makeSUT(
      category: .place,
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      tripID: tripID,
      unscheduledSights: [first, second]
    )

    sut.didSelectSight(first)
    sut.didSelectSight(second)

    let saved = expectation(description: "저장 전달")
    var receivedItem: ItineraryItem?
    saveItineraryItemUseCase.savedPublisher
      .sink { receivedItem = $0; saved.fulfill() }
      .store(in: &cancellables)

    sut.didTapSave()

    wait(for: [saved], timeout: 2.0)
    XCTAssertEqual(receivedItem?.id, second.id)
  }

  func test_sight_ignoresOccupiedHours() {
    let sut = makeSUT(category: .sight, occupiedHours: [9])
    sut.title = "오도리 공원"

    XCTAssertTrue(sut.isHourAvailable)
    XCTAssertTrue(sut.canSave)
  }

  func test_didTapUnschedule_keepsItemButDropsTime() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let deleteItineraryItemUseCase = MockDeleteItineraryItemUseCase()
    let editingItemID = UUID()
    let sut = makeSUT(
      category: .place,
      deleteItineraryItemUseCase: deleteItineraryItemUseCase,
      editingItemID: editingItemID,
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      title: "오도리 공원"
    )

    XCTAssertTrue(sut.canUnschedule)

    let saved = expectation(description: "저장 전달")
    var receivedItem: ItineraryItem?
    saveItineraryItemUseCase.savedPublisher
      .sink { receivedItem = $0; saved.fulfill() }
      .store(in: &cancellables)

    sut.didTapUnschedule()

    wait(for: [saved], timeout: 2.0)
    XCTAssertEqual(receivedItem?.id, editingItemID)
    XCTAssertEqual(receivedItem?.category, .sight)
    XCTAssertEqual(deleteItineraryItemUseCase.deletedItems, [])
  }

  func test_canUnschedule_isFalseForSightAndNewItems() {
    XCTAssertFalse(makeSUT(category: .sight, editingItemID: UUID()).canUnschedule)
    XCTAssertFalse(makeSUT(category: .place).canUnschedule)
    XCTAssertFalse(makeSUT(category: .meal(.dinner), editingItemID: UUID()).canUnschedule)
  }

  // MARK: - Helpers

  private func makeSUT(
    category: ItineraryCategory = .place,
    deleteItineraryItemUseCase: MockDeleteItineraryItemUseCase = MockDeleteItineraryItemUseCase(),
    didFinish: @escaping () -> Void = {},
    editingItemID: UUID? = nil,
    endTime: Date = TestDate.moment(day: 16, hour: 11),
    occupiedHours: Set<Int> = [],
    saveItineraryItemUseCase: MockSaveItineraryItemUseCase = MockSaveItineraryItemUseCase(),
    startTime: Date = TestDate.moment(day: 15, hour: 9),
    title: String = "",
    tripID: UUID = UUID(),
    unscheduledSights: [ItineraryItem] = []
  ) -> ItineraryEditorViewModel {
    ItineraryEditorViewModel(
      actions: ItineraryEditorViewModelActions(didFinish: didFinish),
      category: category,
      deleteItineraryItemUseCase: deleteItineraryItemUseCase,
      editingItemID: editingItemID,
      endTime: endTime,
      occupiedHours: occupiedHours,
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      startTime: startTime,
      title: title,
      tripID: tripID,
      unscheduledSights: unscheduledSights
    )
  }
}
