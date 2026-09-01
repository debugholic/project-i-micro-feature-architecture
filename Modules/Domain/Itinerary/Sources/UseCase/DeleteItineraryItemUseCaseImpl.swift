import DomainItineraryInterface

public struct DeleteItineraryItemUseCaseImpl: DeleteItineraryItemUseCase {
  private let itineraryRepository: ItineraryRepository

  public init(
    itineraryRepository: ItineraryRepository
  ) {
    self.itineraryRepository = itineraryRepository
  }
  
  public func execute(
    request: ItineraryItem
  ) {
    itineraryRepository.remove(
      request
    )
  }
}
