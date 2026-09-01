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


final class ItineraryViewModelTests: XCTestCase {

  private let calendar = Calendar.current
  private var cancellables = Set<AnyCancellable>()

  override func tearDown() {
    cancellables.removeAll()
    super.tearDown()
  }

  func test_init_selectsFirstDay() {
    let plans = makePlans()
    let observeDayPlansUseCase = MockObserveDayPlansUseCase()
    observeDayPlansUseCase.emit(plans)

    let sut = makeSUT(observeDayPlansUseCase: observeDayPlansUseCase)

    let selected = expectation(description: "첫 날 선택")
    sut.$selectedDate
      .filter { $0 == plans[0].date }
      .first()
      .sink { _ in selected.fulfill() }
      .store(in: &cancellables)

    wait(for: [selected], timeout: 2.0)
    XCTAssertEqual(sut.selectedPlan, plans[0])
  }

  func test_didSelectDate_changesSelectedPlan() {
    let plans = makePlans()
    let observeDayPlansUseCase = MockObserveDayPlansUseCase()
    observeDayPlansUseCase.emit(plans)

    let sut = makeSUT(observeDayPlansUseCase: observeDayPlansUseCase)
    waitForPlans(sut, count: plans.count)

    sut.didSelectDate(plans[1].date)

    XCTAssertEqual(sut.selectedPlan, plans[1])
  }

  func test_didTapHour_opensEditorAtThatHour() {
    let plans = makePlans()
    let sut = makeSUT(plans: plans)
    waitForPlans(sut, count: plans.count)

    sut.didTapHour(14)

    XCTAssertEqual(sut.editorViewModel?.target, .item(mealSlot: nil))
    let startTime = sut.editorViewModel?.startTime
    XCTAssertEqual(calendar.component(.hour, from: startTime ?? .distantPast), 14)
    XCTAssertEqual(calendar.component(.minute, from: startTime ?? .distantPast), 0)
    XCTAssertEqual(calendar.startOfDay(for: startTime ?? .distantPast), plans[0].date)
  }

  func test_didTapMeal_opensEditorPresetToThatSlot() {
    let plans = makePlans()
    let sut = makeSUT(plans: plans)
    waitForPlans(sut, count: plans.count)

    sut.didTapMeal(.dinner)

    XCTAssertEqual(sut.editorViewModel?.target, .item(mealSlot: .dinner))
    XCTAssertEqual(
      calendar.startOfDay(for: sut.editorViewModel?.startTime ?? .distantPast),
      plans[0].date
    )
  }

  func test_didSelectLodging_opensEditorWithDefaultRange() {
    let plans = makePlans()
    let sut = makeSUT(plans: plans)
    waitForPlans(sut, count: plans.count)

    sut.didSelectLodging()

    XCTAssertEqual(sut.editorViewModel?.target, .lodging)
    XCTAssertEqual(
      calendar.component(.hour, from: sut.editorViewModel?.startTime ?? .distantPast),
      ItineraryDefaultHour.checkIn
    )
    XCTAssertEqual(
      calendar.component(.hour, from: sut.editorViewModel?.endTime ?? .distantPast),
      ItineraryDefaultHour.checkOut
    )
    XCTAssertEqual(
      calendar.dateComponents(
        [.day],
        from: calendar.startOfDay(for: sut.editorViewModel?.startTime ?? .distantPast),
        to: calendar.startOfDay(for: sut.editorViewModel?.endTime ?? .distantPast)
      ).day,
      1
    )
  }

  func test_didSelectLodging_prefillsLocationWithDaysDestination() {
    let plan = ItineraryFixtures.dayPlan(
      date: calendar.startOfDay(for: TestDate.moment(day: 15)),
      destination: .airport(ReservationFixtures.airport(city: "Sapporo", code: "CTS", country: "Japan"))
    )
    let sut = makeSUT(plans: [plan])
    waitForPlans(sut, count: 1)

    sut.didSelectLodging()

    XCTAssertEqual(sut.editorViewModel?.location, "Sapporo")
  }

  func test_didSelectLodging_whenLodgingExists_opensEditorForIt() {
    let tripID = UUID()
    let lodging = ItineraryFixtures.lodging(name: "다이이치 타키모토칸", tripID: tripID)
    let plan = ItineraryFixtures.dayPlan(
      date: calendar.startOfDay(for: TestDate.moment(day: 15)),
      lodging: lodging
    )
    let sut = makeSUT(plans: [plan])
    waitForPlans(sut, count: 1)

    sut.didSelectLodging()

    XCTAssertEqual(sut.editorViewModel?.title, "다이이치 타키모토칸")
    XCTAssertEqual(sut.editorViewModel?.location, "Sapporo")
    XCTAssertEqual(sut.editorViewModel?.endTime, lodging.checkOut)
    XCTAssertEqual(sut.editorViewModel?.isEditing, true)
  }

  func test_editorDidFinish_closesEditor() {
    let plans = makePlans()
    let sut = makeSUT(plans: plans)
    waitForPlans(sut, count: plans.count)
    sut.didTapHour(9)

    sut.editorViewModel?.didTapCancel()

    XCTAssertNil(sut.editorViewModel)
  }

  func test_didSelectItem_opensEditorForThatItem() {
    let tripID = UUID()
    let item = ItineraryFixtures.itineraryItem(
      startTime: TestDate.moment(day: 15, hour: 13, minute: 12),
      title: "다누키코지 상점가",
      tripID: tripID
    )
    let plan = ItineraryFixtures.dayPlan(
      date: calendar.startOfDay(for: TestDate.moment(day: 15)),
      items: [.custom(item)]
    )
    let sut = makeSUT(plans: [plan])
    waitForPlans(sut, count: 1)

    sut.didSelectItem(item)

    XCTAssertEqual(sut.editorViewModel?.title, "다누키코지 상점가")
    XCTAssertEqual(sut.editorViewModel?.startTime, item.startTime)
    XCTAssertEqual(sut.editorViewModel?.isEditing, true)
    XCTAssertEqual(sut.editorViewModel?.isHourAvailable, true)
  }

  func test_didTapMeal_whenMealExists_opensEditorForIt() {
    let tripID = UUID()
    let dinner = ItineraryFixtures.itineraryItem(
      mealSlot: .dinner,
      startTime: TestDate.moment(day: 15, hour: 19),
      title: "63 로쿠산",
      tripID: tripID
    )
    let plan = ItineraryFixtures.dayPlan(
      date: calendar.startOfDay(for: TestDate.moment(day: 15)),
      items: [.custom(dinner)]
    )
    let sut = makeSUT(plans: [plan])
    waitForPlans(sut, count: 1)

    sut.didTapMeal(.dinner)

    XCTAssertEqual(sut.editorViewModel?.title, "63 로쿠산")
    XCTAssertEqual(sut.editorViewModel?.isEditing, true)
  }

  func test_didTapHour_whenHourIsTaken_doesNothing() {
    let tripID = UUID()
    let plan = ItineraryFixtures.dayPlan(
      date: calendar.startOfDay(for: TestDate.moment(day: 15)),
      items: [.custom(ItineraryFixtures.itineraryItem(startTime: TestDate.moment(day: 15, hour: 13, minute: 12), tripID: tripID))]
    )
    let sut = makeSUT(plans: [plan])
    waitForPlans(sut, count: 1)

    sut.didTapHour(13)

    XCTAssertNil(sut.editorViewModel)
  }

  func test_didTapHour_withoutSelectedDate_doesNothing() {
    let sut = makeSUT()

    sut.didTapHour(9)

    XCTAssertNil(sut.editorViewModel)
  }

  func test_firstItemHour_isHourOfEarliestItem() {
    let tripID = UUID()
    let plan = ItineraryFixtures.dayPlan(
      date: calendar.startOfDay(for: TestDate.moment(day: 15)),
      items: [
        .custom(ItineraryFixtures.itineraryItem(startTime: TestDate.moment(day: 15, hour: 7, minute: 20), tripID: tripID)),
        .custom(ItineraryFixtures.itineraryItem(startTime: TestDate.moment(day: 15, hour: 19), tripID: tripID)),
      ]
    )
    let sut = makeSUT(plans: [plan])
    waitForPlans(sut, count: 1)

    XCTAssertEqual(sut.firstItemHour, 7)
  }

  func test_didTapAddSight_opensRecommendationsForDaysCity() {
    let plan = ItineraryFixtures.dayPlan(
      date: calendar.startOfDay(for: TestDate.moment(day: 15)),
      destination: .lodging("삿포로")
    )
    let recommendAreasUseCase = MockRecommendAreasUseCase()
    let sut = makeSUT(plans: [plan], recommendAreasUseCase: recommendAreasUseCase)
    waitForPlans(sut, count: 1)

    sut.didTapAddSight()

    XCTAssertEqual(sut.recommendationViewModel?.city, "삿포로")
  }

  func test_didTapHour_offersUnscheduledPlacesAsChips() {
    let tripID = UUID()
    let unscheduled = ItineraryFixtures.place(name: "오도리 공원", tripID: tripID)
    let already = ItineraryFixtures.place(name: "삿포로 TV타워", tripID: tripID)
    let plan = ItineraryFixtures.dayPlan(
      date: calendar.startOfDay(for: TestDate.moment(day: 15)),
      items: [
        .custom(
          ItineraryFixtures.itineraryItem(
            placeID: already.id,
            startTime: TestDate.moment(day: 15, hour: 13),
            title: already.name,
            tripID: tripID
          )
        )
      ],
      places: [unscheduled, already]
    )
    let sut = makeSUT(plans: [plan])
    waitForPlans(sut, count: 1)

    sut.didTapHour(10)

    XCTAssertEqual(sut.editorViewModel?.unscheduledPlaces.map(\.name), ["오도리 공원"])
  }

  func test_didTapCreateSight_opensPlaceEditor() {
    let plans = makePlans()
    let sut = makeSUT(plans: plans)
    waitForPlans(sut, count: plans.count)

    sut.didTapCreateSight()

    XCTAssertEqual(sut.editorViewModel?.target, .place)
    XCTAssertEqual(sut.editorViewModel?.isEditing, false)
  }

  func test_didSelectPlace_opensPlaceEditorForIt() {
    let tripID = UUID()
    let place = ItineraryFixtures.place(name: "오도리 공원", tripID: tripID)
    let plan = ItineraryFixtures.dayPlan(
      date: calendar.startOfDay(for: TestDate.moment(day: 15)),
      places: [place]
    )
    let sut = makeSUT(plans: [plan])
    waitForPlans(sut, count: 1)

    sut.didSelectPlace(place)

    XCTAssertEqual(sut.editorViewModel?.title, "오도리 공원")

    XCTAssertEqual(sut.editorViewModel?.target, .place)
  }

  // MARK: - Helpers

  private func makeSUT(
    deleteItineraryItemUseCase: MockDeleteItineraryItemUseCase = MockDeleteItineraryItemUseCase(),
    deleteLodgingUseCase: MockDeleteLodgingUseCase = MockDeleteLodgingUseCase(),
    deleteTripPlaceUseCase: MockDeleteTripPlaceUseCase = MockDeleteTripPlaceUseCase(),
    observeDayPlansUseCase: MockObserveDayPlansUseCase = MockObserveDayPlansUseCase(),
    plans: [DayPlan] = [],
    recommendAreasUseCase: MockRecommendAreasUseCase = MockRecommendAreasUseCase(),
    saveItineraryItemUseCase: MockSaveItineraryItemUseCase = MockSaveItineraryItemUseCase(),
    saveLodgingUseCase: MockSaveLodgingUseCase = MockSaveLodgingUseCase(),
    saveTripPlaceUseCase: MockSaveTripPlaceUseCase = MockSaveTripPlaceUseCase()
  ) -> ItineraryViewModel {
    if !plans.isEmpty { observeDayPlansUseCase.emit(plans) }
    return ItineraryViewModel(
      deleteItineraryItemUseCase: deleteItineraryItemUseCase,
      deleteLodgingUseCase: deleteLodgingUseCase,
      deleteTripPlaceUseCase: deleteTripPlaceUseCase,
      observeDayPlansUseCase: observeDayPlansUseCase,
      recommendAreasUseCase: recommendAreasUseCase,
      saveItineraryItemUseCase: saveItineraryItemUseCase,
      saveLodgingUseCase: saveLodgingUseCase,
      saveTripPlaceUseCase: saveTripPlaceUseCase,
      trip: TripFixtures.trip()
    )
  }

  private func makePlans() -> [DayPlan] {
    [
      ItineraryFixtures.dayPlan(date: calendar.startOfDay(for: TestDate.moment(day: 15))),
      ItineraryFixtures.dayPlan(date: calendar.startOfDay(for: TestDate.moment(day: 16))),
    ]
  }

  private func waitForPlans(_ sut: ItineraryViewModel, count: Int) {
    let loaded = expectation(description: "일정 로드")
    sut.$dayPlans
      .filter { $0.count == count }
      .first()
      .sink { _ in loaded.fulfill() }
      .store(in: &cancellables)
    wait(for: [loaded], timeout: 2.0)
  }
}
