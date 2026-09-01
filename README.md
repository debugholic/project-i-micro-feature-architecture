# Project I — Micro Feature Architecture

[Project A-Z](#project-a-z) 의 I 단계.

단계마다 새로운 기술 스택을 하나씩 더해가며, 조금씩 다른 기능을 구현해 나갑니다.
I 단계는 **Micro Feature Architecture**를 추가합니다 — H에서 카탈로그 하나만 로컬 패키지로 떼어냈다면, 여기서는 **앱을 통째로 모듈로 쪼갭니다.** 앱 타깃에 남은 Swift 파일은 4개입니다.

## 다루는 기술

- UIKit (Programmatic) · SwiftUI · MVVM · Diffable Data Source
- Combine (상태 바인딩) · async/await
- Clean Architecture (계층 분리 · 의존성 역전 · Use Case · DI 컨테이너)
- XCTest
- Swift Package Manager (로컬 패키지 · 리소스 번들 · `Bundle.module`)
- **Micro Feature Architecture** (모듈 5종 세트 · Interface 의존 · Example 앱) ← 이번 단계 추가분

## 무엇이 달라졌나

H의 앱은 `Domain` · `Data` · `Presentation` 폴더 안에 104개 파일이 있었습니다. 폴더는 계층을 말할 뿐이라, 어느 파일이 무엇을 봐도 컴파일러가 막지 않았습니다.

I에서는 그 경계를 **모듈**로 만듭니다.

```
Modules/Package.swift          36개 타깃을 선언
Modules/
├── Core/      Network · Storage · TravelGuide
├── Shared/    Common · DesignSystem
├── Domain/    Trip · Itinerary · Reservation · Recommendation
├── Data/      Trip · Itinerary · Reservation · Recommendation
└── Feature/   Trip · Itinerary · Reservation
```

`FeatureTrip` 이 `DomainTripInterface` 만 보고 `DataTrip` 은 못 보는 게, 이제 규칙이 아니라 **빌드 에러**입니다.

## 모듈 하나는 다섯 조각이다

```
Modules/Feature/Trip/
├── Interface/Sources     FeatureTripInterface    화면 생성 계약
├── Sources               FeatureTrip             구현
├── Testing/Sources       FeatureTripTesting      다른 모듈에 줄 스텁
└── Tests/Sources         FeatureTripTests

Projects/Feature/Trip/
├── FeatureTrip.xcodeproj                         Example 앱 타깃
└── Example/Sources                               단독 실행
```

`Interface` 가 갈라져 있어서 모듈끼리 구현을 안 보고 붙습니다.

```
FeatureTrip ──▶ FeatureItineraryInterface ◀── FeatureItinerary
                          ▲
                          └── FeatureItineraryTesting (스텁)
```

**Example은 SPM으로 만들 수 없습니다.** `.testTarget` 은 SPM의 정식 타깃이지만 iOS 앱 product 타입은 없습니다. 그래서 다섯 조각 중 Example만 `Projects/` 의 Xcode 프로젝트가 맡습니다 — 모듈마다 프로젝트 하나, 타깃 하나입니다. **이 수동 작업이 다음 단계에서 Tuist를 넣는 이유**가 됩니다.

## 조립과 전환을 가른다

```swift
AppComponent          // 조립 — Storage · Repository · UseCase · 모듈 Component
AppFlowCoordinator    // 전환 — push · pop
```

각 모듈은 `TripComponent` 같은 프로토콜로 화면을 내놓고, 앱은 그것만 압니다. Example도 같은 구조를 그대로 씁니다 — `Projects/Feature/<M>/Example/Sources` 에 `AppComponent` 와 `AppFlowCoordinator` 가 같은 이름으로 있습니다. 저장소만 메모리일 뿐, 나머지는 앱과 같은 실제 구현입니다.

## 읽기와 쓰기를 가른다

```
읽기   Storage.elementsPublisher → Component 가 ViewModel 에 직접 꽂음
쓰기   ViewModel → UseCase → Repository → Storage
```

읽기 경로에서 `ObserveTripsUseCase` 는 `tripRepository.tripsPublisher` 를 그대로 흘려보내기만 했습니다. 통과 계층을 지우고, 규칙이 있는 `ObserveDayPlansUseCase` 만 남겼습니다. 그것도 조립은 `DayPlanBuilder` 로 빼서 UseCase에는 구독과 변환만 둡니다.

저장은 `UserDefaultsStorageImpl` 로 바뀌어 앱을 껐다 켜도 남습니다.

```swift
public protocol Storage<Element> {
  var elementsPublisher: AnyPublisher<[Element], Never> { get }
  func save(_ element: Element)
  func delete(_ element: Element)
}
```

`InMemoryStorageImpl` 과 `UserDefaultsStorageImpl` 이 같은 계약을 채우고, 앱은 어느 쪽인지 모릅니다. K 단계의 Core Data가 들어올 자리입니다.

## 도메인을 다시 나눴다

H의 `ItineraryCategory` 하나에 성격이 다른 세 축이 들어 있었습니다.

```swift
enum ItineraryCategory {
  case lodging      // 범위를 갖는 다른 개념
  case meal(MealSlot)  // 화면의 식사 칸을 가리키는 태그
  case place        // 시각 있음
  case sight        // 시각 없음
}
```

상태를 바꾸려면 종류를 바꿔야 했고, 그게 `시간 정하기` 스위치로 화면에 새어 나왔습니다. 시각 없는 곳을 담으려고 **시간대를 눌러 들어가서 시각을 다시 빼는** 순서였고요.

타입을 나눴습니다.

| 타입 | 갖는 것 | 나오는 곳 |
|---|---|---|
| `TripPlace` | 이름 · 날짜 · 추천 분류 | 주요 관광 정보 |
| `ItineraryItem` | 시각 · `mealSlot?` · `placeID?` | 시간표 |
| `Lodging` | 체크인 · 체크아웃 · 지역 | 숙소 칸 |

토글이 사라지고 `직접 추가` 가 생겼습니다. 추천에서 담을 때 버려지던 음식점·쇼핑·명소 분류도 `TripPlace` 가 보관합니다.

## H 단계와 달라진 점

| | H (SPM) | I (+ MFA) |
|---|---|---|
| 앱 타깃의 Swift 파일 | 104 | **4** |
| 모듈 | `TravelGuide` 1개 | **36개 타깃 · 6개 product** |
| 모듈 경계 | 폴더 | **컴파일러** |
| Example 앱 | — | **모듈마다 1개** |
| 저장 | 메모리 | **UserDefaults** |
| 테스트 | 61 + 7 | **69** (6개 타깃) |

## 구조

```
ProjectI.xcworkspace
Modules/            Package.swift + 36 타깃
Projects/
├── App/            App.xcodeproj · Sources (4 파일)
└── Feature/
    ├── Trip/       FeatureTrip.xcodeproj · Example/Sources
    ├── Itinerary/  FeatureItinerary.xcodeproj · Example/Sources
    └── Reservation/ FeatureReservation.xcodeproj · Example/Sources
```

## 테스트

`swift test` 는 쓸 수 없습니다. 패키지에 UIKit 타깃이 있어서 macOS 빌드가 거기서 깨집니다. 스킴이 시뮬레이터에서 실행합니다.

| 스킴 | 도는 테스트 | 개수 |
|---|---|---|
| `App` | `CoreTravelGuideTests` | 7 |
| `FeatureTripExample` | `DomainTripTests` · `FeatureTripTests` | 10 |
| `FeatureReservationExample` | `FeatureReservationTests` | 3 |
| `FeatureItineraryExample` | `DomainItineraryTests` · `FeatureItineraryTests` | 49 |

```
xcodebuild test -workspace ProjectI.xcworkspace -scheme FeatureItineraryExample -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## API 키 설정

AeroDataBox(RapidAPI) 키는 F부터 동일하게 주입합니다. `Projects/App/Secrets.local.xcconfig` 에 둡니다 — `Config.xcconfig` 옆이어야 `#include?` 가 찾습니다.

```
RAPIDAPI_KEY = your_rapidapi_key
```

## 빌드 · 실행

Xcode 16+ / iOS 16.0+ / Swift 5.9+.

```
open ProjectI.xcworkspace
```

`App` 은 전체 앱, `Feature*Example` 은 그 모듈만 링크한 단독 앱입니다.

## Project A-Z

실무에서 다뤄온 기술을 단계별로 정리하는 프로젝트입니다.

| | 추가 스택 |
|---|---|
| A | UIKit + MVVM |
| B | Diffable Data Source |
| C | Combine |
| D | async/await |
| E | Clean Architecture |
| F | XCTest |
| G | SwiftUI |
| H | SPM 모듈화 |
| **I** | **Micro Feature Architecture** |
| J | Tuist |
| K | Core Data |
| L | CloudKit |
| M | APNs |
| N | SwiftData |
| O | Objective-C + libexif |
| P | Swift Testing |
| Q | UI Test |
| R | CI/CD (GitHub Actions) |

각 단계는 별도 레포로 관리합니다.
