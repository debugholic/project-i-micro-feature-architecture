public protocol TripRepository {
  func save(
    _ trip: Trip
  )

  func remove(
    _ trip: Trip
  )
}
