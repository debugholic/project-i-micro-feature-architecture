struct RecommendAreasUseCaseImpl: RecommendAreasUseCase {
  private let placeRecommendationRepository: PlaceRecommendationRepository

  init(
    placeRecommendationRepository: PlaceRecommendationRepository
  ) {
    self.placeRecommendationRepository = placeRecommendationRepository
  }
  
  func execute(
    request city: String
  ) async throws -> [RecommendedArea] {
    try await placeRecommendationRepository.areas(
      in: city
    )
  }
}
