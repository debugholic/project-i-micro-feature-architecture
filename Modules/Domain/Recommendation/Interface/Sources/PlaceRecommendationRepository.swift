public protocol PlaceRecommendationRepository {
  func areas(
    in city: String
  ) async throws -> [RecommendedArea]
}
