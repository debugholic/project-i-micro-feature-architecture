import DomainItineraryInterface

public struct SaveLodgingUseCaseImpl: SaveLodgingUseCase {
  private let lodgingRepository: LodgingRepository

  public init(
    lodgingRepository: LodgingRepository
  ) {
    self.lodgingRepository = lodgingRepository
  }

  public func execute(
    request lodging: Lodging
  ) {
    lodgingRepository.save(
      lodging
    )
  }
}
