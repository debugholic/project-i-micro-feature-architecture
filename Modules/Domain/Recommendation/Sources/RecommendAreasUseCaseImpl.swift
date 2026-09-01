import DomainRecommendationInterface

public struct RecommendAreasUseCaseImpl: RecommendAreasUseCase {
  private let placeRecommendationRepository: PlaceRecommendationRepository

  public init(
    placeRecommendationRepository: PlaceRecommendationRepository
  ) {
    self.placeRecommendationRepository = placeRecommendationRepository
  }
  
  public func execute(
    request city: String
  ) async throws -> [RecommendedArea] {
    try await placeRecommendationRepository.areas(
      in: city
    )
  }
}
