import DomainItineraryInterface

public struct DeleteTripPlaceUseCaseImpl: DeleteTripPlaceUseCase {
  private let tripPlaceRepository: TripPlaceRepository

  public init(
    tripPlaceRepository: TripPlaceRepository
  ) {
    self.tripPlaceRepository = tripPlaceRepository
  }

  public func execute(
    request place: TripPlace
  ) {
    tripPlaceRepository.remove(
      place
    )
  }
}
