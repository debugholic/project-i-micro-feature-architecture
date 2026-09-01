import DomainItineraryInterface

public struct SaveTripPlaceUseCaseImpl: SaveTripPlaceUseCase {
  private let tripPlaceRepository: TripPlaceRepository

  public init(
    tripPlaceRepository: TripPlaceRepository
  ) {
    self.tripPlaceRepository = tripPlaceRepository
  }

  public func execute(
    request place: TripPlace
  ) {
    tripPlaceRepository.save(
      place
    )
  }
}
