import DomainItineraryInterface

public struct DeleteLodgingUseCaseImpl: DeleteLodgingUseCase {
  private let lodgingRepository: LodgingRepository

  public init(
    lodgingRepository: LodgingRepository
  ) {
    self.lodgingRepository = lodgingRepository
  }

  public func execute(
    request lodging: Lodging
  ) {
    lodgingRepository.remove(
      lodging
    )
  }
}
