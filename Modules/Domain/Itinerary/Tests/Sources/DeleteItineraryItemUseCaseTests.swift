import Combine
import DomainItineraryInterface
import DomainItineraryTesting
import DomainReservationInterface
import DomainReservationTesting
import DomainTripInterface
import DomainTripTesting
import Foundation
import SharedCommon
import SharedCommonTesting
import XCTest
@testable import DomainItinerary


final class DeleteItineraryItemUseCaseTests: XCTestCase {

  func test_execute_removesGivenItemFromRepository() async throws {
    let itineraryRepository = MockItineraryRepository()
    let sut: any DeleteItineraryItemUseCase = DeleteItineraryItemUseCaseImpl(
      itineraryRepository: itineraryRepository
    )
    let item = ItineraryFixtures.itineraryItem(tripID: UUID())

    try await sut.execute(request: item)

    XCTAssertEqual(itineraryRepository.removedItems, [item])
  }
}
