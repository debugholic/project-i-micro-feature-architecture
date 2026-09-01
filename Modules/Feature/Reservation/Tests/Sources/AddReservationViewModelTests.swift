import Combine
import DomainReservationInterface
import DomainTripInterface
import DomainTripTesting
import FeatureReservationInterface
import SharedCommonTesting
import XCTest
@testable import FeatureReservation

final class AddReservationViewModelTests: XCTestCase {

  private var cancellables = Set<AnyCancellable>()

  override func tearDown() {
    cancellables.removeAll()
    super.tearDown()
  }

  private func makeSUT(
    createTripUseCase: MockCreateTripUseCase = MockCreateTripUseCase(),
    didFinish: @escaping () -> Void = {}
  ) -> AddReservationViewModel {
    AddReservationViewModel(
      actions: AddReservationViewModelActions(didFinish: didFinish),
      createTripUseCase: createTripUseCase
    )
  }

  func test_lookup_success_transitionsToIdleAndFinishes() {
    let createTripUseCase = MockCreateTripUseCase()
    let finished = expectation(description: "흐름 종료 요청")
    let sut = makeSUT(createTripUseCase: createTripUseCase, didFinish: { finished.fulfill() })

    var sawLoading = false
    let idle = expectation(description: "loading 후 idle 복귀")
    sut.$state
      .dropFirst()
      .sink { state in
        switch state {
        case .loading: sawLoading = true
        case .idle where sawLoading: idle.fulfill()
        default: break
        }
      }
      .store(in: &cancellables)

    sut.lookup(
      outboundDate: TestDate.date,
      outboundNumber: "KE705",
      returnDate: nil,
      returnNumber: nil
    )

    wait(for: [idle, finished], timeout: 1.0)
    XCTAssertEqual(createTripUseCase.receivedRequests.count, 1)
    XCTAssertEqual(createTripUseCase.receivedRequests.first?.outboundNumber, "KE705")
  }

  func test_lookup_blankOutboundNumber_doesNothing() {
    let createTripUseCase = MockCreateTripUseCase()
    let sut = makeSUT(createTripUseCase: createTripUseCase)

    sut.lookup(
      outboundDate: TestDate.date,
      outboundNumber: "   ",
      returnDate: nil,
      returnNumber: nil
    )

    XCTAssertTrue(createTripUseCase.receivedRequests.isEmpty)
    if case .idle = sut.state {} else { XCTFail("state는 idle로 유지돼야 함") }
  }

  func test_lookup_useCaseFails_setsFailedState() {
    let createTripUseCase = MockCreateTripUseCase()
    createTripUseCase.error = ReservationError.notFound
    var finished = false
    let sut = makeSUT(createTripUseCase: createTripUseCase, didFinish: { finished = true })

    let failed = expectation(description: "state failed")
    sut.$state
      .dropFirst()
      .sink { if case .failed = $0 { failed.fulfill() } }
      .store(in: &cancellables)

    sut.lookup(
      outboundDate: TestDate.date,
      outboundNumber: "KE999",
      returnDate: nil,
      returnNumber: nil
    )

    wait(for: [failed], timeout: 1.0)
    XCTAssertFalse(finished)
  }
}
