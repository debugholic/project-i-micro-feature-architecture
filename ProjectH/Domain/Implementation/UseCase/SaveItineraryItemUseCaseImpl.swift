struct SaveItineraryItemUseCaseImpl: SaveItineraryItemUseCase {
  private let itineraryRepository: ItineraryRepository

  init(
    itineraryRepository: ItineraryRepository
  ) {
    self.itineraryRepository = itineraryRepository
  }
  
  func execute(
    request: ItineraryItem
  ) {
    itineraryRepository.save(
      request
    )
  }
}
