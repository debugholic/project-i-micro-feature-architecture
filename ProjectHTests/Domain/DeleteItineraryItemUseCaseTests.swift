import XCTest
@testable import ProjectH

final class DeleteItineraryItemUseCaseTests: XCTestCase {

  func test_execute_removesGivenItemFromRepository() async throws {
    let itineraryRepository = MockItineraryRepository()
    let sut: any DeleteItineraryItemUseCase = DeleteItineraryItemUseCaseImpl(
      itineraryRepository: itineraryRepository
    )
    let item = Fixtures.itineraryItem(tripID: UUID())

    try await sut.execute(request: item)

    XCTAssertEqual(itineraryRepository.removedItems, [item])
  }
}
