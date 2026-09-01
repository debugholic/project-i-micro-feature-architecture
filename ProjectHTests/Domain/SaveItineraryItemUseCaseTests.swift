import Combine
import XCTest
@testable import ProjectH

final class SaveItineraryItemUseCaseTests: XCTestCase {

  func test_execute_savesGivenItemToRepository() async throws {
    let itineraryRepository = MockItineraryRepository()
    let sut: any SaveItineraryItemUseCase = SaveItineraryItemUseCaseImpl(
      itineraryRepository: itineraryRepository
    )
    let item = Fixtures.itineraryItem(tripID: UUID())

    try await sut.execute(request: item)

    XCTAssertEqual(itineraryRepository.savedItems, [item])
  }

  func test_execute_sameID_replacesInsteadOfAppending() async throws {
    let itineraryRepository = MockItineraryRepository()
    let sut: any SaveItineraryItemUseCase = SaveItineraryItemUseCaseImpl(
      itineraryRepository: itineraryRepository
    )
    let tripID = UUID()
    let id = UUID()

    try await sut.execute(request: Fixtures.itineraryItem(id: id, title: "오도리 공원", tripID: tripID))
    try await sut.execute(request: Fixtures.itineraryItem(id: id, title: "삿포로 TV타워", tripID: tripID))

    var received: [ItineraryItem] = []
    let cancellable = itineraryRepository.itemsPublisher(for: tripID).sink { received = $0 }
    cancellable.cancel()

    XCTAssertEqual(received.map(\.title), ["삿포로 TV타워"])
  }
}
