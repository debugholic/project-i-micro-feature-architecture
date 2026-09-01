import Combine
import XCTest
@testable import ProjectH

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
    XCTAssertEqual(plans[1].items, [])
  }

  func test_execute_sortsStoredItemsAndFlightsByStartTime() async throws {
    let itineraryRepository = MockItineraryRepository()
    let sut = makeSUT(itineraryRepository: itineraryRepository)
    let trip = makeTrip(roundTrip: false)

    let lunch = Fixtures.itineraryItem(
      category: .meal(.lunch),
      startTime: Fixtures.moment(day: 15, hour: 12, minute: 30),
      title: "에비소바 이치겐",
      tripID: trip.id
    )
    let terminal = Fixtures.itineraryItem(
      category: .place,
      startTime: Fixtures.moment(day: 15, hour: 5, minute: 20),
      title: "인천공항 제1터미널",
      tripID: trip.id
    )
    itineraryRepository.save(lunch)
    itineraryRepository.save(terminal)

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.first?.items, [
      .custom(terminal),
      .flight(trip.outbound, .departure),
      .flight(trip.outbound, .arrival),
      .custom(lunch),
    ])
  }

  func test_execute_ignoresItemsOfOtherTrips() async throws {
    let itineraryRepository = MockItineraryRepository()
    let sut = makeSUT(itineraryRepository: itineraryRepository)
    let trip = makeTrip(roundTrip: false)

    itineraryRepository.save(Fixtures.itineraryItem(tripID: UUID()))

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.first?.items.count, 2)
  }

  func test_execute_addsDayOutsideTripRangeWhenItemHasOne() async throws {
    let itineraryRepository = MockItineraryRepository()
    let sut = makeSUT(itineraryRepository: itineraryRepository)
    let trip = makeTrip(roundTrip: false)

    itineraryRepository.save(
      Fixtures.itineraryItem(
        startTime: Fixtures.moment(day: 16, hour: 9),
        tripID: trip.id
      )
    )

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.map(\.date), [day(of: 15), day(of: 16)])
  }

  func test_execute_tracksOriginAndDestinationPerDay() async throws {
    let sut = makeSUT()
    let trip = makeTrip(roundTrip: true)

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.map { ItineraryFormatter.route($0) }, [
      "Seoul | Sapporo",
      "Sapporo | Sapporo",
      "Sapporo | Sapporo",
      "Sapporo | Sapporo",
      "Sapporo | Seoul",
    ])
  }

  func test_execute_lodgingSpansItsNights() async throws {
    let itineraryRepository = MockItineraryRepository()
    let sut = makeSUT(itineraryRepository: itineraryRepository)
    let trip = makeTrip(roundTrip: true)

    itineraryRepository.save(
      Fixtures.lodging(
        checkIn: Fixtures.moment(day: 15, hour: 15),
        checkOut: Fixtures.moment(day: 16, hour: 10),
        location: "Noboribetsu",
        title: "다이이치 타키모토칸",
        tripID: trip.id
      )
    )
    itineraryRepository.save(
      Fixtures.lodging(
        checkIn: Fixtures.moment(day: 16, hour: 15),
        checkOut: Fixtures.moment(day: 19, hour: 11),
        location: "Sapporo",
        title: "베셀 호텔",
        tripID: trip.id
      )
    )

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.map { ItineraryFormatter.route($0) }, [
      "Seoul | Noboribetsu",
      "Noboribetsu | Sapporo",
      "Sapporo | Sapporo",
      "Sapporo | Sapporo",
      "Sapporo | Seoul",
    ])
    XCTAssertEqual(plans.map { $0.lodging?.title }, [
      "다이이치 타키모토칸",
      "베셀 호텔",
      "베셀 호텔",
      "베셀 호텔",
      nil,
    ])
  }

  func test_execute_timelineExcludesLodgingAndMeal() async throws {
    let itineraryRepository = MockItineraryRepository()
    let sut = makeSUT(itineraryRepository: itineraryRepository)
    let trip = makeTrip(roundTrip: false)

    let park = Fixtures.itineraryItem(
      startTime: Fixtures.moment(day: 15, hour: 13),
      title: "오도리 공원",
      tripID: trip.id
    )
    itineraryRepository.save(park)
    itineraryRepository.save(Fixtures.lodging(tripID: trip.id))
    itineraryRepository.save(
      Fixtures.itineraryItem(
        category: .meal(.dinner),
        startTime: Fixtures.moment(day: 15, hour: 19),
        title: "63 로쿠산",
        tripID: trip.id
      )
    )

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

  func test_execute_lodgingWithoutLocation_doesNotMoveDestination() async throws {
    let itineraryRepository = MockItineraryRepository()
    let sut = makeSUT(itineraryRepository: itineraryRepository)
    let trip = makeTrip(roundTrip: false)

    itineraryRepository.save(
      Fixtures.lodging(
        checkIn: Fixtures.moment(day: 15, hour: 15),
        checkOut: Fixtures.moment(day: 16, hour: 11),
        location: nil,
        tripID: trip.id
      )
    )

    let plans = try await plans(of: sut, trip: trip)

    XCTAssertEqual(plans.first.map { ItineraryFormatter.route($0) }, "Seoul | Sapporo")
  }

  // MARK: - Helpers

  private func makeSUT(
    itineraryRepository: MockItineraryRepository = MockItineraryRepository()
  ) -> any ObserveDayPlansUseCase {
    ObserveDayPlansUseCaseImpl(itineraryRepository: itineraryRepository)
  }

  private func plans(
    of sut: any ObserveDayPlansUseCase,
    trip: Trip
  ) async throws -> [DayPlan] {
    var received: [DayPlan] = []
    let publisher = try await sut.execute(request: trip)
    let cancellable = publisher.sink { received = $0 }
    cancellable.cancel()
    return received
  }

  private func day(of day: Int) -> Date {
    calendar.startOfDay(for: Fixtures.moment(day: day))
  }

  private func makeTrip(roundTrip: Bool) -> Trip {
    let sapporo = Fixtures.airport(city: "Sapporo", code: "CTS", country: "Japan")
    let outbound = Fixtures.flightLeg(
      arrival: Fixtures.movement(
        airport: sapporo,
        date: Fixtures.moment(day: 15, hour: 10),
        time: "10:00"
      ),
      departure: Fixtures.movement(
        date: Fixtures.moment(day: 15, hour: 7, minute: 20),
        time: "07:20"
      ),
      flightNumber: "KE765"
    )
    guard roundTrip else { return Fixtures.trip(outbound: outbound) }

    let returnLeg = Fixtures.flightLeg(
      arrival: Fixtures.movement(
        date: Fixtures.moment(day: 19, hour: 17),
        time: "17:00"
      ),
      departure: Fixtures.movement(
        airport: sapporo,
        date: Fixtures.moment(day: 19, hour: 14),
        time: "14:00"
      ),
      flightNumber: "KE766"
    )
    return Fixtures.trip(outbound: outbound, returnLeg: returnLeg)
  }
}
