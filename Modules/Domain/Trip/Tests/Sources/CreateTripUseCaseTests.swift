import DomainReservationInterface
import DomainReservationTesting
import DomainTripInterface
import DomainTripTesting
import SharedCommonTesting
import XCTest
@testable import DomainTrip

final class CreateTripUseCaseTests: XCTestCase {

  private var tripRepository: MockTripRepository!
  private var reservationRepository: MockReservationRepository!
  private var sut: CreateTripUseCaseImpl!

  override func setUp() {
    super.setUp()
    tripRepository = MockTripRepository()
    reservationRepository = MockReservationRepository()
    sut = CreateTripUseCaseImpl(
      reservationRepository: reservationRepository,
      tripRepository: tripRepository
    )
  }

  override func tearDown() {
    tripRepository = nil
    reservationRepository = nil
    sut = nil
    super.tearDown()
  }

  private func request(
    outboundNumber: String = "KE705",
    returnDate: Date? = nil,
    returnNumber: String? = nil
  ) -> CreateTripRequest {
    CreateTripRequest(
      outboundDate: TestDate.date,
      outboundNumber: outboundNumber,
      returnDate: returnDate,
      returnNumber: returnNumber
    )
  }

  func test_execute_oneWay_addsTripWithOutboundOnly() async throws {
    let outbound = ReservationFixtures.flightLeg(flightNumber: "KE705")
    reservationRepository.stub("KE705", with: .success(outbound))

    try await sut.execute(request: request())

    XCTAssertEqual(tripRepository.savedTrips.count, 1)
    XCTAssertEqual(tripRepository.savedTrips.first?.outbound, outbound)
    XCTAssertNil(tripRepository.savedTrips.first?.returnLeg)
  }

  func test_execute_roundTrip_addsTripWithOutboundAndReturn() async throws {
    let outbound = ReservationFixtures.flightLeg(flightNumber: "KE705")
    let returnLeg = ReservationFixtures.flightLeg(
      arrival: ReservationFixtures.movement(time: "18:00"),
      departure: ReservationFixtures.movement(
        airport: ReservationFixtures.airport(city: "Tokyo", code: "NRT", country: "Japan"),
        time: "15:00"
      ),
      flightNumber: "KE706"
    )
    reservationRepository.stub("KE705", with: .success(outbound))
    reservationRepository.stub("KE706", with: .success(returnLeg))

    try await sut.execute(
      request: request(returnDate: TestDate.date, returnNumber: "KE706")
    )

    XCTAssertEqual(tripRepository.savedTrips.count, 1)
    XCTAssertEqual(tripRepository.savedTrips.first?.returnLeg, returnLeg)
  }

  func test_execute_emptyReturnNumber_treatedAsOneWay() async throws {
    reservationRepository.stub("KE705", with: .success(ReservationFixtures.flightLeg()))

    try await sut.execute(
      request: request(returnDate: TestDate.date, returnNumber: "")
    )

    XCTAssertEqual(reservationRepository.calls.count, 1)
    XCTAssertNil(tripRepository.savedTrips.first?.returnLeg)
  }

  func test_execute_outboundFetchFails_propagatesErrorAndDoesNotAddTrip() async {
    reservationRepository.stub("KE705", with: .failure(ReservationError.notFound))

    do {
      try await sut.execute(request: request())
      XCTFail("에러가 전파돼야 함")
    } catch {
      XCTAssertTrue(tripRepository.savedTrips.isEmpty)
    }
  }

  func test_execute_returnFetchFails_propagatesErrorAndDoesNotAddTrip() async {
    reservationRepository.stub("KE705", with: .success(ReservationFixtures.flightLeg()))
    reservationRepository.stub("KE706", with: .failure(ReservationError.notFound))

    do {
      try await sut.execute(
        request: request(returnDate: TestDate.date, returnNumber: "KE706")
      )
      XCTFail("에러가 전파돼야 함")
    } catch {
      XCTAssertTrue(tripRepository.savedTrips.isEmpty)
    }
  }
}
