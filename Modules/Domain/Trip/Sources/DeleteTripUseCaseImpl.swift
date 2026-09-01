import DomainTripInterface

public struct DeleteTripUseCaseImpl: DeleteTripUseCase {
  private let tripRepository: TripRepository

  public init(
    tripRepository: TripRepository
  ) {
    self.tripRepository = tripRepository
  }

  public func execute(
    request: Trip
  ) {
    tripRepository.remove(
      request
    )
  }
}
