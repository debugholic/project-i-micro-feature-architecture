public protocol ItineraryRepository {
  func remove(
    _ item: ItineraryItem
  )

  func save(
    _ item: ItineraryItem
  )
}
