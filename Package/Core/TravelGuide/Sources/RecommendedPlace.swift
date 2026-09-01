public struct RecommendedPlace: Hashable, Decodable, Sendable {
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

public enum PlaceCategory: String, Hashable, Decodable, Sendable {
  case food
  case shopping
  case sight
}
