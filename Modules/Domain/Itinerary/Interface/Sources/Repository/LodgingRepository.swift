public protocol LodgingRepository {
  func remove(
    _ lodging: Lodging
  )

  func save(
    _ lodging: Lodging
  )
}
