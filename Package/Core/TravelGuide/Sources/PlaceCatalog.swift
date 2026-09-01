import Foundation

public struct PlaceCatalog {
  private let cities: [GuideCity]

  public init() {
    self.init(
      cities: PlaceCatalog.bundledCities
    )
  }

  init(
    cities: [GuideCity]
  ) {
    self.cities = cities
  }

  public var cityNames: [String] {
    cities.map(\.name)
  }

  public func areas(
    in city: String
  ) -> [GuideArea] {
    let key = PlaceCatalog.normalized(city)
    guard let match = cities.first(where: { $0.matches(key) }) else { return [] }
    return match.areas
  }

  static func normalized(_ value: String) -> String {
    value.trimmingCharacters(
      in: .whitespacesAndNewlines
    ).lowercased()
  }

  private static let bundledCities: [GuideCity] = {
    guard let url = Bundle.module.url(forResource: "places", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let catalog = try? JSONDecoder().decode(GuideCatalog.self, from: data)
    else { return [] }
    return catalog.cities
  }()
}

struct GuideCatalog: Decodable {
  let cities: [GuideCity]
}

struct GuideCity: Decodable {
  let areas: [GuideArea]
  let names: [String]

  var name: String { names.first ?? "" }

  func matches(
    _ normalizedKey: String
  ) -> Bool {
    names.contains { PlaceCatalog.normalized($0) == normalizedKey }
  }
}

public struct GuideArea: Hashable, Decodable, Sendable {
  public let names: [String]
  public let places: [RecommendedPlace]

  public var name: String { names.first ?? "" }

  public init(
    names: [String],
    places: [RecommendedPlace]
  ) {
    self.names = names
    self.places = places
  }
}
