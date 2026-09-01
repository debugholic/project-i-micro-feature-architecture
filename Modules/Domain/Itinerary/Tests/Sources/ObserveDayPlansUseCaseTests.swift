import Combine
import DomainItineraryInterface
import DomainItineraryTesting
import DomainReservationTesting
import DomainTripInterface
import DomainTripTesting
import Foundation
import SharedCommonTesting
import XCTest
@testable import DomainItinerary

final class ObserveDayPlansUseCaseTests: XCTestCase {

  private let calendar = Calendar.current

  func test_execute_emitsOneDayPlanPerTripDay() async throws {
    let sut = makeSUT()
    let trip = makeTrip(roundTrip: true)

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.map(\.date), (15...19).map { day(of: $0) })
  }

  func test_execute_oneWayTrip_emitsSingleDay() async throws {
    let sut = makeSUT()
    let trip = makeTrip(roundTrip: false)

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.map(\.date), [day(of: 15)])
  }

  func test_execute_placesFlightItemsOnTheirOwnDays() async throws {
    let sut = makeSUT()
    let trip = makeTrip(roundTrip: true)

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.first?.items, [
      .flight(trip.outbound, .departure),
      .flight(trip.outbound, .arrival),
    ])
    XCTAssertEqual(plans.last?.items.count, 2)
  }

  func test_execute_sortsStoredItemsAndFlightsByStartTime() async throws {
    let sut = makeSUT()
    let trip = makeTrip(roundTrip: false)

    let lunch = ItineraryFixtures.itineraryItem(
      mealSlot: .lunch,
      startTime: TestDate.moment(day: 15, hour: 12, minute: 30),
      title: "에비소바 이치겐",
      tripID: trip.id
    )
    let terminal = ItineraryFixtures.itineraryItem(
      startTime: TestDate.moment(day: 15, hour: 5, minute: 20),
      title: "인천공항 제1터미널",
      tripID: trip.id
    )
    save(items: [lunch, terminal])

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.first?.items, [
      .custom(terminal),
      .flight(trip.outbound, .departure),
      .flight(trip.outbound, .arrival),
      .custom(lunch),
    ])
  }

  func test_execute_ignoresItemsOfOtherTrips() async throws {
    let sut = makeSUT()
    let trip = makeTrip(roundTrip: false)

    save(items: [ItineraryFixtures.itineraryItem(tripID: UUID())])

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.first?.items.count, 2)
  }

  func test_execute_addsDayOutsideTripRangeWhenItemHasOne() async throws {
    let sut = makeSUT()
    let trip = makeTrip(roundTrip: false)

    save(items: [
      ItineraryFixtures.itineraryItem(
        startTime: TestDate.moment(day: 16, hour: 9),
        tripID: trip.id
      )
    ])

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.map(\.date), [day(of: 15), day(of: 16)])
  }

  func test_execute_tracksOriginAndDestinationPerDay() async throws {
    let sut = makeSUT()
    let trip = makeTrip(roundTrip: true)

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.map { route($0) }, [
      "Seoul | Sapporo",
      "Sapporo | Sapporo",
      "Sapporo | Sapporo",
      "Sapporo | Sapporo",
      "Sapporo | Seoul",
    ])
  }

  func test_execute_lodgingSpansItsNights() async throws {
    let sut = makeSUT()
    let trip = makeTrip(roundTrip: true)

    save(lodgings: [
      ItineraryFixtures.lodging(
        checkIn: TestDate.moment(day: 15, hour: 15),
        checkOut: TestDate.moment(day: 16, hour: 10),
        location: "Noboribetsu",
        name: "다이이치 타키모토칸",
        tripID: trip.id
      ),
      ItineraryFixtures.lodging(
        checkIn: TestDate.moment(day: 16, hour: 15),
        checkOut: TestDate.moment(day: 19, hour: 11),
        location: "Sapporo",
        name: "베셀 호텔",
        tripID: trip.id
      ),
    ])

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.map { route($0) }, [
      "Seoul | Noboribetsu",
      "Noboribetsu | Sapporo",
      "Sapporo | Sapporo",
      "Sapporo | Sapporo",
      "Sapporo | Seoul",
    ])
    XCTAssertEqual(plans.map { $0.lodging?.name }, [
      "다이이치 타키모토칸",
      "베셀 호텔",
      "베셀 호텔",
      "베셀 호텔",
      nil,
    ])
  }

  func test_execute_lodgingWithoutLocation_doesNotMoveDestination() async throws {
    let sut = makeSUT()
    let trip = makeTrip(roundTrip: false)

    save(lodgings: [
      ItineraryFixtures.lodging(
        checkIn: TestDate.moment(day: 15, hour: 15),
        checkOut: TestDate.moment(day: 16, hour: 11),
        location: nil,
        tripID: trip.id
      )
    ])

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.first.map { route($0) }, "Seoul | Sapporo")
  }

  func test_execute_timelineExcludesMeal() async throws {
    let sut = makeSUT()
    let trip = makeTrip(roundTrip: false)

    let park = ItineraryFixtures.itineraryItem(
      startTime: TestDate.moment(day: 15, hour: 13),
      title: "오도리 공원",
      tripID: trip.id
    )
    save(items: [
      park,
      ItineraryFixtures.itineraryItem(
        mealSlot: .dinner,
        startTime: TestDate.moment(day: 15, hour: 19),
        title: "63 로쿠산",
        tripID: trip.id
      ),
    ])
    save(lodgings: [ItineraryFixtures.lodging(tripID: trip.id)])

    let plan = try await plans(of: sut, trip: trip).first

    XCTAssertEqual(plan?.items.count, 4)
    XCTAssertEqual(plan?.timelineItems, [
      .flight(trip.outbound, .departure),
      .flight(trip.outbound, .arrival),
      .custom(park),
    ])
    XCTAssertNotNil(plan?.lodging)
    XCTAssertNotNil(plan?.meal(.dinner))
  }

  // MARK: - 담아둔 곳

  func test_execute_groupsPlacesByTheirDay() async throws {
    let sut = makeSUT()
    let trip = makeTrip(roundTrip: true)

    let first = ItineraryFixtures.place(
      date: TestDate.moment(day: 15),
      name: "오도리 공원",
      tripID: trip.id
    )
    let second = ItineraryFixtures.place(
      date: TestDate.moment(day: 16),
      name: "다누키코지 상점가",
      tripID: trip.id
    )
    save(places: [first, second, ItineraryFixtures.place(tripID: UUID())])

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.first?.places.map(\.name), ["오도리 공원"])
    XCTAssertEqual(plans.dropFirst().first?.places.map(\.name), ["다누키코지 상점가"])
  }

  func test_execute_linksScheduledItemToItsPlace() async throws {
    let sut = makeSUT()
    let trip = makeTrip(roundTrip: false)

    let place = ItineraryFixtures.place(
      date: TestDate.moment(day: 15),
      name: "오도리 공원",
      tripID: trip.id
    )
    save(places: [place])
    save(items: [
      ItineraryFixtures.itineraryItem(
        placeID: place.id,
        startTime: TestDate.moment(day: 15, hour: 13),
        title: place.name,
        tripID: trip.id
      )
    ])

    let plan = try await plans(of: sut, trip: trip).first

    XCTAssertNotNil(plan?.item(for: place))
  }

  // MARK: - Helpers

  private let itemsSubject = CurrentValueSubject<[ItineraryItem], Never>([])
  private let lodgingsSubject = CurrentValueSubject<[Lodging], Never>([])
  private let placesSubject = CurrentValueSubject<[TripPlace], Never>([])
  private let tripsSubject = CurrentValueSubject<[Trip], Never>([])

  private func makeSUT() -> any ObserveDayPlansUseCase {
    ObserveDayPlansUseCaseImpl(
      items: itemsSubject.eraseToAnyPublisher(),
      lodgings: lodgingsSubject.eraseToAnyPublisher(),
      places: placesSubject.eraseToAnyPublisher(),
      trips: tripsSubject.eraseToAnyPublisher()
    )
  }

  private func save(items: [ItineraryItem]) {
    itemsSubject.send(itemsSubject.value + items)
  }

  private func save(lodgings: [Lodging]) {
    lodgingsSubject.send(lodgingsSubject.value + lodgings)
  }

  private func save(places: [TripPlace]) {
    placesSubject.send(placesSubject.value + places)
  }

  private func route(_ plan: DayPlan) -> String {
    "\(placeName(plan.origin)) | \(placeName(plan.destination))"
  }

  private func placeName(_ place: DayPlanPlace) -> String {
    switch place {
    case let .airport(airport): return airport.city ?? airport.code ?? "도착지"
    case let .lodging(name): return name
    }
  }

  private func plans(
    of sut: any ObserveDayPlansUseCase,
    trip: Trip
  ) async throws -> [DayPlan] {
    tripsSubject.send([trip])

    var received: [DayPlan] = []
    let publisher = try await sut.execute(request: trip.id)
    let cancellable = publisher.sink { received = $0 }
    cancellable.cancel()
    return received
  }

  private func day(of day: Int) -> Date {
    calendar.startOfDay(for: TestDate.moment(day: day))
  }

  private func makeTrip(roundTrip: Bool) -> Trip {
    let sapporo = ReservationFixtures.airport(city: "Sapporo", code: "CTS", country: "Japan")
    let outbound = ReservationFixtures.flightLeg(
      arrival: ReservationFixtures.movement(
        airport: sapporo,
        date: TestDate.moment(day: 15, hour: 10),
        time: "10:00"
      ),
      departure: ReservationFixtures.movement(
        date: TestDate.moment(day: 15, hour: 7, minute: 20),
        time: "07:20"
      ),
      flightNumber: "KE765"
    )
    guard roundTrip else { return TripFixtures.trip(outbound: outbound) }

    let returnLeg = ReservationFixtures.flightLeg(
      arrival: ReservationFixtures.movement(
        date: TestDate.moment(day: 19, hour: 17),
        time: "17:00"
      ),
      departure: ReservationFixtures.movement(
        airport: sapporo,
        date: TestDate.moment(day: 19, hour: 14),
        time: "14:00"
      ),
      flightNumber: "KE766"
    )
    return TripFixtures.trip(outbound: outbound, returnLeg: returnLeg)
  }
}
