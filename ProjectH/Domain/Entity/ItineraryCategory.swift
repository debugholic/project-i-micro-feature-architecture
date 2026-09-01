nonisolated enum ItineraryCategory: Hashable {
  case lodging
  case meal(MealSlot)
  case place
  case sight
}

nonisolated enum MealSlot: Hashable, CaseIterable {
  case breakfast
  case lunch
  case dinner
  case lateNight
}
