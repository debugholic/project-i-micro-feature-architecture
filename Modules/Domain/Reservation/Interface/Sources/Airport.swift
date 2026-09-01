public nonisolated struct Airport: Codable, Hashable {
  public let city: String?
  public let code: String?
  public let country: String?

  public init(
    city: String?,
    code: String?,
    country: String?
  ) {
    self.city = city
    self.code = code
    self.country = country
  }
}
