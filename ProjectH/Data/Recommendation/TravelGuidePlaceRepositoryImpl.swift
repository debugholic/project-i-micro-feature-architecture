import CoreTravelGuide

nonisolated struct TravelGuidePlaceRepositoryImpl: PlaceRecommendationRepository {
  private let catalog: PlaceCatalog

  init(
    catalog: PlaceCatalog = PlaceCatalog()
  ) {
    self.catalog = catalog
  }
  
  func areas(
    in city: String
  ) async throws -> [RecommendedArea] {
    catalog.areas(
      in: city
    ).map { area in
      RecommendedArea(
        name: area.name,
        places: area.places.map { place in
          RecommendedPlace(
            category: place.category.toDomain(),
            name: place.name
          )
        }
      )
    }
  }
}

private extension CoreTravelGuide.PlaceCategory {
  func toDomain() -> ProjectH.PlaceCategory {
    switch self {
    case .food: return .food
    case .shopping: return .shopping
    case .sight: return .sight
    }
  }
}
