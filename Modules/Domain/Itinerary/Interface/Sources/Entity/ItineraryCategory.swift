public nonisolated enum ItineraryCategory: Codable, Hashable {
  case lodging
  case meal(MealSlot)
  case place
  case sight
}

public nonisolated enum MealSlot: Codable, Hashable, CaseIterable {
  case breakfast
  case lunch
  case dinner
  case lateNight
}
