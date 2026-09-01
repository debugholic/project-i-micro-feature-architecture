struct DeleteItineraryItemUseCaseImpl: DeleteItineraryItemUseCase {
  private let itineraryRepository: ItineraryRepository

  init(
    itineraryRepository: ItineraryRepository
  ) {
    self.itineraryRepository = itineraryRepository
  }
  
  func execute(
    request: ItineraryItem
  ) {
    itineraryRepository.remove(
      request
    )
  }
}
