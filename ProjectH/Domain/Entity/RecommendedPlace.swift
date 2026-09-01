nonisolated struct RecommendedArea: Hashable {
  let name: String
  let places: [RecommendedPlace]

  init(
    name: String,
    places: [RecommendedPlace]
  ) {
    self.name = name
    self.places = places
  }
}

nonisolated struct RecommendedPlace: Hashable {
  let category: PlaceCategory
  let name: String

  init(
    category: PlaceCategory,
    name: String
  ) {
    self.category = category
    self.name = name
  }
}

nonisolated enum PlaceCategory: Hashable, CaseIterable {
  case food
  case shopping
  case sight
}
