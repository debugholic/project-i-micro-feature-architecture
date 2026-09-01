import DomainRecommendationInterface

public final class MockRecommendAreasUseCase: RecommendAreasUseCase {
  public var areas: [RecommendedArea] = []

  public private(set) var receivedCities: [String] = []

  public init() {}

  public func execute(request city: String) -> [RecommendedArea] {
    receivedCities.append(city)
    return areas
  }
}
