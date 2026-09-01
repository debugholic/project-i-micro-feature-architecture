// swift-tools-version: 5.9
import Foundation
import PackageDescription

// MARK: - Dependency

typealias TargetDependency = PackageDescription.Target.Dependency

extension TargetDependency {
  static func core(_ component: Component.Core) -> Self {
    .byName(name: "Core\(component.rawValue)")
  }

  static func shared(_ component: Component.Shared) -> Self {
    .byName(name: "Shared\(component.rawValue)")
  }

  static func sharedTesting(_ component: Component.Shared) -> Self {
    .byName(name: "Shared\(component.rawValue)Testing")
  }

  static func domain(_ module: Product) -> Self {
    .byName(name: "Domain\(module.rawValue)")
  }

  static func domainInterface(_ module: Product) -> Self {
    .byName(name: "Domain\(module.rawValue)Interface")
  }

  static func domainTesting(_ module: Product) -> Self {
    .byName(name: "Domain\(module.rawValue)Testing")
  }

  static func data(_ module: Product) -> Self {
    .byName(name: "Data\(module.rawValue)")
  }

  static func dataInterface(_ module: Product) -> Self {
    .byName(name: "Data\(module.rawValue)Interface")
  }

  static func feature(_ module: Product) -> Self {
    .byName(name: "Feature\(module.rawValue)")
  }

  static func featureInterface(_ module: Product) -> Self {
    .byName(name: "Feature\(module.rawValue)Interface")
  }

  static func featureTesting(_ module: Product) -> Self {
    .byName(name: "Feature\(module.rawValue)Testing")
  }
}

// MARK: - Component

enum Component {
  enum Core: String, CaseIterable {
    case network = "Network"
    case storage = "Storage"
    case travelGuide = "TravelGuide"
  }

  enum Shared: String, CaseIterable {
    case common = "Common"
    case designSystem = "DesignSystem"
  }

  case core(_ component: Core, dependencies: [TargetDependency] = [])
  case coreTests(_ component: Core, dependencies: [TargetDependency] = [])
  case shared(_ component: Shared, dependencies: [TargetDependency] = [])
  case sharedTesting(_ component: Shared, dependencies: [TargetDependency] = [])

  case domainInterface(_ module: Product, dependencies: [TargetDependency] = [])
  case domain(_ module: Product, dependencies: [TargetDependency] = [])
  case domainTesting(_ module: Product, dependencies: [TargetDependency] = [])
  case domainTests(_ module: Product, dependencies: [TargetDependency] = [])

  case dataInterface(_ module: Product, dependencies: [TargetDependency] = [])
  case data(_ module: Product, dependencies: [TargetDependency] = [])
  case dataTests(_ module: Product, dependencies: [TargetDependency] = [])

  case featureInterface(_ module: Product, dependencies: [TargetDependency] = [])
  case feature(_ module: Product, dependencies: [TargetDependency] = [])
  case featureTesting(_ module: Product, dependencies: [TargetDependency] = [])
  case featureTests(_ module: Product, dependencies: [TargetDependency] = [])

  var name: String {
    switch self {
    case .core(let component, _): "Core\(component.rawValue)"
    case .coreTests(let component, _): "Core\(component.rawValue)Tests"
    case .shared(let component, _): "Shared\(component.rawValue)"
    case .sharedTesting(let component, _): "Shared\(component.rawValue)Testing"
    case .domainInterface(let module, _): "Domain\(module.rawValue)Interface"
    case .domain(let module, _): "Domain\(module.rawValue)"
    case .domainTesting(let module, _): "Domain\(module.rawValue)Testing"
    case .domainTests(let module, _): "Domain\(module.rawValue)Tests"
    case .dataInterface(let module, _): "Data\(module.rawValue)Interface"
    case .data(let module, _): "Data\(module.rawValue)"
    case .dataTests(let module, _): "Data\(module.rawValue)Tests"
    case .featureInterface(let module, _): "Feature\(module.rawValue)Interface"
    case .feature(let module, _): "Feature\(module.rawValue)"
    case .featureTesting(let module, _): "Feature\(module.rawValue)Testing"
    case .featureTests(let module, _): "Feature\(module.rawValue)Tests"
    }
  }

  var path: String {
    switch self {
    case .core(let component, _): "Core/\(component.rawValue)"
    case .coreTests(let component, _): "Core/\(component.rawValue)/Tests"
    case .shared(let component, _): "Shared/\(component.rawValue)"
    case .sharedTesting(let component, _): "Shared/\(component.rawValue)/Testing"
    case .domainInterface(let module, _): "Domain/\(module.rawValue)/Interface"
    case .domain(let module, _): "Domain/\(module.rawValue)"
    case .domainTesting(let module, _): "Domain/\(module.rawValue)/Testing"
    case .domainTests(let module, _): "Domain/\(module.rawValue)/Tests"
    case .dataInterface(let module, _): "Data/\(module.rawValue)/Interface"
    case .data(let module, _): "Data/\(module.rawValue)"
    case .dataTests(let module, _): "Data/\(module.rawValue)/Tests"
    case .featureInterface(let module, _): "Feature/\(module.rawValue)/Interface"
    case .feature(let module, _): "Feature/\(module.rawValue)"
    case .featureTesting(let module, _): "Feature/\(module.rawValue)/Testing"
    case .featureTests(let module, _): "Feature/\(module.rawValue)/Tests"
    }
  }

  var dependencies: [TargetDependency] {
    switch self {
    case .core(_, let dependencies),
      .coreTests(_, let dependencies),
      .shared(_, let dependencies),
      .sharedTesting(_, let dependencies),
      .domainInterface(_, let dependencies),
      .domain(_, let dependencies),
      .domainTesting(_, let dependencies),
      .domainTests(_, let dependencies),
      .dataInterface(_, let dependencies),
      .data(_, let dependencies),
      .dataTests(_, let dependencies),
      .featureInterface(_, let dependencies),
      .feature(_, let dependencies),
      .featureTesting(_, let dependencies),
      .featureTests(_, let dependencies):
      dependencies
    }
  }

  var isTest: Bool {
    switch self {
    case .coreTests, .domainTests, .dataTests, .featureTests: true
    default: false
    }
  }

  var resources: [PackageDescription.Resource] {
    exists("Resources") ? [.process("Resources")] : []
  }

  var excludes: [String] {
    isTest ? [] : ["Example", "Interface", "Testing", "Tests"].filter(exists)
  }

  private func exists(_ directory: String) -> Bool {
    let manifestDirectory = URL(fileURLWithPath: #file).deletingLastPathComponent()
    let fullPath = manifestDirectory.appendingPathComponent("\(path)/\(directory)").path

    return FileManager.default.fileExists(atPath: fullPath)
  }

  /// Xcode 16 은 SwiftUI 를 import 한 모듈에 SwiftUICore 오토링크를 박는다.
  /// SwiftUICore 는 iOS 18 부터 존재해서 그 아래 기기에서 dyld 로드가 실패한다.
  var swiftSettings: [PackageDescription.SwiftSetting] {
    [
      .unsafeFlags([
        "-Xfrontend", "-disable-autolink-framework",
        "-Xfrontend", "SwiftUICore",
      ])
    ]
  }

  var target: PackageDescription.Target {
    isTest
      ? .testTarget(
        name: name,
        dependencies: dependencies,
        path: path,
        sources: ["Sources"],
        resources: resources,
        swiftSettings: swiftSettings
      )
      : .target(
        name: name,
        dependencies: dependencies,
        path: path,
        exclude: excludes,
        sources: ["Sources"],
        resources: resources,
        swiftSettings: swiftSettings
      )
  }
}

// MARK: - Product

enum Product: String, CaseIterable {
  // Module
  case itinerary = "Itinerary"
  case recommendation = "Recommendation"
  case reservation = "Reservation"
  case trip = "Trip"

  // Kit
  case core = "Core"
  case shared = "Shared"

  var product: PackageDescription.Product {
    switch self {
    case .core, .shared:
      .library(name: "\(rawValue)Kit", targets: targets.map(\.name))
    default:
      .library(name: rawValue, targets: targets.map(\.name))
    }
  }

  /// 테스트 타깃은 라이브러리로 내보내지 않는다.
  var targets: [Component] {
    components.filter { !$0.isTest }
  }

  var components: [Component] {
    switch self {
    // MARK: - Module: Itinerary
    case .itinerary:
      [
        .domainInterface(
          self,
          dependencies: [
            .domainInterface(.trip),
            .shared(.common),
          ]
        ),
        .domain(
          self,
          dependencies: [
            .domainInterface(self),
            .domainInterface(.reservation),
            .domainInterface(.trip),
          ]
        ),
        .domainTesting(
          self,
          dependencies: [
            .domainInterface(self),
            .domainInterface(.reservation),
            .domainTesting(.reservation),
            .sharedTesting(.common),
          ]
        ),
        .domainTests(
          self,
          dependencies: [
            .domain(self),
            .domainTesting(self),
            .domainTesting(.reservation),
            .domainTesting(.trip),
            .sharedTesting(.common),
          ]
        ),
        .data(
          self,
          dependencies: [
            .core(.storage),
            .domainInterface(self),
          ]
        ),
        .featureInterface(
          self,
          dependencies: [
            .domainInterface(.trip)
          ]
        ),
        .feature(
          self,
          dependencies: [
            .domainInterface(self),
            .domainInterface(.recommendation),
            .domainInterface(.reservation),
            .domainInterface(.trip),
            .featureInterface(self),
            .featureInterface(.reservation),
            .shared(.common),
            .shared(.designSystem),
          ]
        ),
        .featureTesting(
          self,
          dependencies: [
            .domainInterface(.trip),
            .featureInterface(self),
          ]
        ),
        .featureTests(
          self,
          dependencies: [
            .domainTesting(self),
            .domainTesting(.recommendation),
            .domainTesting(.reservation),
            .domainTesting(.trip),
            .feature(self),
            .featureTesting(self),
            .sharedTesting(.common),
          ]
        ),
      ]

    // MARK: - Module: Recommendation
    case .recommendation:
      [
        .domainInterface(
          self,
          dependencies: [
            .shared(.common)
          ]
        ),
        .domain(
          self,
          dependencies: [
            .domainInterface(self)
          ]
        ),
        .domainTesting(
          self,
          dependencies: [
            .domainInterface(self),
            .sharedTesting(.common),
          ]
        ),
        .data(
          self,
          dependencies: [
            .core(.travelGuide),
            .domainInterface(self),
          ]
        ),
      ]

    // MARK: - Module: Reservation
    case .reservation:
      [
        .domainInterface(
          self,
          dependencies: [
            .shared(.common)
          ]
        ),
        .domainTesting(
          self,
          dependencies: [
            .domainInterface(self),
            .sharedTesting(.common),
          ]
        ),
        .data(
          self,
          dependencies: [
            .core(.network),
            .domainInterface(self),
            .shared(.common),
          ]
        ),
        .featureInterface(
          self,
          dependencies: [
            .domainInterface(self),
            .shared(.common),
          ]
        ),
        .feature(
          self,
          dependencies: [
            .domainInterface(self),
            .domainInterface(.trip),
            .featureInterface(self),
            .shared(.common),
            .shared(.designSystem),
          ]
        ),
        .featureTesting(
          self,
          dependencies: [
            .domainInterface(.trip),
            .featureInterface(self),
          ]
        ),
        .featureTests(
          self,
          dependencies: [
            .domainInterface(self),
            .domainTesting(self),
            .domainTesting(.trip),
            .feature(self),
            .featureTesting(self),
          ]
        ),
      ]

    // MARK: - Module: Trip
    case .trip:
      [
        .domainInterface(
          self,
          dependencies: [
            .domainInterface(.reservation),
            .shared(.common),
          ]
        ),
        .domain(
          self,
          dependencies: [
            .domainInterface(self),
            .domainInterface(.reservation),
          ]
        ),
        .domainTesting(
          self,
          dependencies: [
            .domainInterface(self),
            .domainTesting(.reservation),
            .sharedTesting(.common),
          ]
        ),
        .domainTests(
          self,
          dependencies: [
            .domain(self),
            .domainTesting(self),
          ]
        ),
        .data(
          self,
          dependencies: [
            .core(.storage),
            .domainInterface(self),
          ]
        ),
        .featureInterface(
          self,
          dependencies: [
            .domainInterface(self),
            .shared(.common),
          ]
        ),
        .feature(
          self,
          dependencies: [
            .domainInterface(self),
            .domainInterface(.reservation),
            .featureInterface(self),
            .featureInterface(.itinerary),
            .featureInterface(.reservation),
            .shared(.common),
            .shared(.designSystem),
          ]
        ),
        .featureTesting(
          self,
          dependencies: [
            .domainInterface(.trip),
            .featureInterface(self),
          ]
        ),
        .featureTests(
          self,
          dependencies: [
            .domainTesting(self),
            .feature(self),
            .featureTesting(self),
          ]
        ),
      ]

    // MARK: - Kit: Core
    case .core:
      Component.Core.allCases.flatMap { component -> [Component] in
        switch component {
        case .travelGuide:
          [
            .core(component),
            .coreTests(
              component,
              dependencies: [.core(component)]
            ),
          ]
        default:
          [.core(component)]
        }
      }

    // MARK: - Kit: Shared
    case .shared:
      Component.Shared.allCases.flatMap { component -> [Component] in
        switch component {
        case .common:
          [
            .shared(component),
            .sharedTesting(
              component,
              dependencies: [.shared(component)]
            ),
          ]
        default:
          [.shared(component)]
        }
      }
    }
  }
}

let package = Package(
  name: "ProjectI",
  platforms: [.iOS(.v16), .macOS(.v13)],
  products: Product.allCases.map(\.product),
  targets: Product.allCases.flatMap(\.components).map(\.target)
)
