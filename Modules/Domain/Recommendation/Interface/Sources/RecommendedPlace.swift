public nonisolated struct RecommendedArea: Hashable {
  public let name: String
  public let places: [RecommendedPlace]

  public init(
    name: String,
    places: [RecommendedPlace]
  ) {
    self.name = name
    self.places = places
  }
}

public nonisolated struct RecommendedPlace: Hashable {
  public let category: PlaceCategory
  public let name: String

  public init(
    category: PlaceCategory,
    name: String
  ) {
    self.category = category
    self.name = name
  }
}

public nonisolated enum PlaceCategory: Codable, Hashable, CaseIterable {
  case food
  case shopping
  case sight
}
