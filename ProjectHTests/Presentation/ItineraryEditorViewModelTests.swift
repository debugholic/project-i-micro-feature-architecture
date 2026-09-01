import Combine
import XCTest
@testable import ProjectH

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
      startTime: Fixtures.moment(day: 15, hour: 13, minute: 30)
    )
    sut.title = "오도리 공원"

    XCTAssertFalse(sut.isHourAvailable)
    XCTAssertFalse(sut.canSave)

    sut.startTime = Fixtures.moment(day: 15, hour: 14)
    XCTAssertTrue(sut.canSave)
  }

  func test_lodging_savesRangeAndLocation() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let checkIn = Fixtures.moment(day: 15, hour: 14)
    let checkOut = Fixtures.moment(day: 17, hour: 10)
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
    XCTAssertFalse(sut.showsTimeToggle)
    XCTAssertEqual(receivedItem?.startTime, checkIn)
    XCTAssertEqual(receivedItem?.endTime, checkOut)
    XCTAssertEqual(receivedItem?.location, "Noboribetsu")
  }

  func test_lodging_checkOutBeforeCheckIn_cannotSave() {
    let sut = makeSUT(
      category: .lodging,
      endTime: Fixtures.moment(day: 15, hour: 10),
      startTime: Fixtures.moment(day: 15, hour: 15)
    )
    sut.title = "베셀 호텔"

    XCTAssertFalse(sut.isRangeValid)
    XCTAssertFalse(sut.canSave)

    sut.endTime = Fixtures.moment(day: 16, hour: 11)
    XCTAssertTrue(sut.canSave)
  }

  func test_meal_ignoresTimeEntirely() {
    let sut = makeSUT(
      category: .meal(.dinner),
      occupiedHours: [9],
      startTime: Fixtures.moment(day: 15, hour: 9)
    )
    sut.title = "63 로쿠산"

    XCTAssertFalse(sut.showsTimeToggle)
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

  func test_hasTime_switchesBetweenSightAndPlace() {
    let sut = makeSUT(category: .sight, hasTime: false)
    sut.title = "오도리 공원"

    XCTAssertEqual(sut.category, .sight)

    sut.hasTime = true
    XCTAssertEqual(sut.category, .place)
  }

  func test_didSelectSight_promotesSameItem() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let tripID = UUID()
    let sight = Fixtures.itineraryItem(category: .sight, title: "오도리 공원", tripID: tripID)
    let sut = makeSUT(
      category: .place,
      hasTime: true,
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      startTime: Fixtures.moment(day: 15, hour: 13),
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
    XCTAssertEqual(receivedItem?.startTime, Fixtures.moment(day: 15, hour: 13))
  }

  func test_didSelectSight_thenRenaming_createsNewItemInstead() {
    let saveItineraryItemUseCase = MockSaveItineraryItemUseCase()
    let tripID = UUID()
    let sight = Fixtures.itineraryItem(category: .sight, title: "오도리 공원", tripID: tripID)
    let sut = makeSUT(
      category: .place,
      hasTime: true,
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
    let first = Fixtures.itineraryItem(category: .sight, title: "오도리 공원", tripID: tripID)
    let second = Fixtures.itineraryItem(category: .sight, title: "삿포로 TV타워", tripID: tripID)
    let sut = makeSUT(
      category: .place,
      hasTime: true,
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
    let sut = makeSUT(category: .sight, hasTime: false, occupiedHours: [9])
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
      hasTime: true,
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
    XCTAssertFalse(makeSUT(category: .sight, editingItemID: UUID(), hasTime: false).canUnschedule)
    XCTAssertFalse(makeSUT(category: .place, hasTime: true).canUnschedule)
    XCTAssertFalse(makeSUT(category: .meal(.dinner), editingItemID: UUID()).canUnschedule)
  }

  // MARK: - Helpers

  private func makeSUT(
    category: ItineraryCategory = .place,
    deleteItineraryItemUseCase: MockDeleteItineraryItemUseCase = MockDeleteItineraryItemUseCase(),
    didFinish: @escaping () -> Void = {},
    editingItemID: UUID? = nil,
    endTime: Date = Fixtures.moment(day: 16, hour: 11),
    hasTime: Bool = true,
    occupiedHours: Set<Int> = [],
    saveItineraryItemUseCase: MockSaveItineraryItemUseCase = MockSaveItineraryItemUseCase(),
    startTime: Date = Fixtures.moment(day: 15, hour: 9),
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
      hasTime: hasTime,
      occupiedHours: occupiedHours,
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      startTime: startTime,
      title: title,
      tripID: tripID,
      unscheduledSights: unscheduledSights
    )
  }
}
