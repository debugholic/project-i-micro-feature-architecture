import XCTest
@testable import CoreTravelGuide

final class PlaceCatalogTests: XCTestCase {

  func test_areas_findsCityByEnglishName() {
    let sut = PlaceCatalog()

    let areas = sut.areas(in: "Sapporo")

    XCTAssertEqual(areas.map(\.name), ["오도리·삿포로역", "스스키노", "마루야마·모이와", "시 외곽"])
  }

  func test_areas_findsCityByKoreanAlias() {
    let sut = PlaceCatalog()

    XCTAssertEqual(sut.areas(in: "삿포로"), sut.areas(in: "Sapporo"))
  }

  func test_areas_ignoresCaseAndSurroundingSpaces() {
    let sut = PlaceCatalog()

    XCTAssertEqual(sut.areas(in: "  sapporo "), sut.areas(in: "Sapporo"))
  }

  func test_areas_unknownCity_returnsEmpty() {
    let sut = PlaceCatalog()

    XCTAssertEqual(sut.areas(in: "Atlantis"), [])
  }

  func test_areas_splitCityIntoWalkableAreas() {
    let sut = PlaceCatalog()

    let seoul = sut.areas(in: "Seoul")

    XCTAssertTrue(seoul.contains { $0.name == "경복궁·북촌" })
    XCTAssertTrue(seoul.contains { $0.name == "성수" })
    XCTAssertFalse(seoul.contains { $0.places.isEmpty })
  }

  func test_bundledCatalog_loadsEveryCity() {
    let sut = PlaceCatalog()

    XCTAssertEqual(sut.cityNames, ["Sapporo", "Noboribetsu", "Tokyo", "Osaka", "Seoul"])
  }

  func test_areas_keepsCatalogOrder() {
    let sut = PlaceCatalog(
      cities: [
        GuideCity(
          areas: [
            GuideArea(names: ["두번째 구역"], places: [RecommendedPlace(category: .food, name: "가")]),
            GuideArea(names: ["첫번째 구역"], places: [RecommendedPlace(category: .sight, name: "나")]),
          ],
          names: ["Testville"]
        )
      ]
    )

    XCTAssertEqual(sut.areas(in: "Testville").map(\.name), ["두번째 구역", "첫번째 구역"])
  }
}
