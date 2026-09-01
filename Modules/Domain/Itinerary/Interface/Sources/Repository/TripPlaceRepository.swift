public protocol TripPlaceRepository {
  func remove(
    _ place: TripPlace
  )

  func save(
    _ place: TripPlace
  )
}
