import DomainItineraryInterface

public struct SaveItineraryItemUseCaseImpl: SaveItineraryItemUseCase {
  private let itineraryRepository: ItineraryRepository

  public init(
    itineraryRepository: ItineraryRepository
  ) {
    self.itineraryRepository = itineraryRepository
  }
  
  public func execute(
    request: ItineraryItem
  ) {
    itineraryRepository.save(
      request
    )
  }
}
