# Project H — SPM 모듈화

[Project A-Z](#project-a-z) 의 H 단계.

단계마다 새로운 기술 스택을 하나씩 더해가며, 조금씩 다른 기능을 구현해 나갑니다.
H 단계는 **Swift Package Manager**를 추가합니다 — **앱을 통째로 쪼개는 게 아니라**, 추천 여행지 카탈로그 하나를 `TravelGuide` 로컬 패키지로 떼어 내고 앱에 결합합니다. 앱의 `Domain`/`Data`/`Presentation`은 폴더 그대로 두고, 그 위에 **주요 관광 정보** 기능을 얹었습니다.

## 다루는 기술

- UIKit (Programmatic, Storyboard 없음) · MVVM · Diffable Data Source
- Combine (상태 바인딩)
- async/await (`URLSession`/`Codable` 실제 API 호출)
- Clean Architecture (계층 분리 · 의존성 역전 · Use Case · DI 컨테이너)
- XCTest
- SwiftUI (`UIHostingController` 상호운용)
- **Swift Package Manager** (로컬 패키지 · 리소스 번들 · `Bundle.module`) ← 이번 단계 추가분

## 새 기능 — 주요 관광 정보

G에서 만든 일정표는 **시각이 정해진 것만** 담을 수 있었습니다. 실제로 여행을 짤 때는 "여기 가고 싶다"를 먼저 모으고 시간은 나중에 정합니다. 그래서 그날 갈 곳을 모아두는 칸을 만들었습니다.

```
주요 관광 정보
  13:30 오도리 공원      삿포로 TV타워
  다누키코지 상점가       + 추천에서 담기
```

**추천에서 담기**를 누르면 그날 도시의 추천 목록이 뜹니다. 도시 전체가 아니라 **구역별로 나뉘어** 있습니다 — 서울에서 경복궁·성수·홍대를 하루에 도는 건 무리니까요. 구역은 그날에 고정되지 않아서, 낮에는 성수 섹션에서 담고 저녁에는 남산 섹션에서 담아도 됩니다.

### 시각은 나중에 정한다

같은 항목이 시각을 갖느냐 아니냐로만 갈립니다.

| | 시각 | 시간표 | 주요 관광 정보 |
|---|---|---|---|
| `.sight` | 없음 | ✗ | ✓ |
| `.place` | 있음 | ✓ | ✓ |

**표에는 둘 다 나옵니다.** 시간표에 장소를 넣으면 관광 정보에도 자동으로 나타나는데, 복사해 넣는 게 아니라 **같은 항목을 두 군데서 보여주는 것**이라 동기화할 게 없습니다.

빈 시간대를 눌러 장소를 넣을 때는 **담아둔 곳이 칩으로 뜹니다.** 하나 고르면 그 항목이 같은 `id`로 시각을 얻어 시간표에 올라갑니다 — 새 항목이 생기지 않습니다. 다만 칩을 고른 뒤 **이름을 고치면 새 항목**이 됩니다. 저장 시점에 이름이 그대로일 때만 그 칩에 묶으므로, 원래 칩을 덮어쓰지 않습니다.

반대 방향도 필요합니다. 시간표와 관광 정보가 같은 항목이라 삭제하면 양쪽에서 사라지므로, 시각만 빼는 **`시간표에서 빼기`** 를 따로 뒀습니다. 에디터의 `시간 정하기` 스위치가 같은 일을 하지만 삭제 버튼 옆에서는 보이지 않아서요.

```swift
var category: ItineraryCategory {
  guard showsTimeToggle else { return baseCategory }
  return hasTime ? .place : .sight
}
```

## `TravelGuide` — SPM이라서 하는 일

추천 목록은 앱이 아니라 **로컬 패키지**에 있습니다.

```
Modules/TravelGuide/
├── Package.swift
├── Sources/TravelGuide/
│   ├── PlaceCatalog.swift          도시 → 구역 → 장소
│   ├── RecommendedPlace.swift
│   └── Resources/places.json       5개 도시 · 18개 구역
└── Tests/TravelGuideTests/         7개
```

핵심은 **`resources:` 와 `Bundle.module`** 입니다. 앱 타깃에 JSON을 넣을 때와 접근 경로가 다릅니다 — `Bundle.main`으로 찾으면 못 찾습니다.

```swift
.target(name: "TravelGuide", resources: [.process("Resources")])
```
```swift
guard let url = Bundle.module.url(forResource: "places", withExtension: "json") else { ... }
```

**시뮬레이터 없이 테스트가 돕니다.** 패키지가 iOS·macOS 양쪽을 지원하고 UI 의존이 없어서, `swift test` 한 줄로 7개가 0.006초에 끝납니다. 앱을 띄우지 않아도 카탈로그가 검증됩니다.

### 모듈명과 타입명을 다르게 둔 이유

패키지 이름은 `TravelGuide`인데 안의 타입은 `PlaceCatalog`입니다. 둘 다 `TravelGuide`면 다른 모듈에서 `TravelGuide.PlaceCategory`라고 쓸 때 **모듈 한정인지 중첩 타입인지 모호해집니다.** SwiftUI의 `Section`·`Label`을 중첩 타입으로 가렸던 것과 같은 종류의 문제입니다.

## 패키지는 앱이 아는 대상이 아니다

앱은 `TravelGuide`를 모릅니다. Domain이 프로토콜을 갖고, Data만 패키지를 압니다.

```
Domain      PlaceRecommendationRepository        ← 앱이 아는 건 이것뿐
Data        TravelGuidePlaceRepositoryImpl       ← 여기서만 import TravelGuide
```

`RecommendedPlace`도 Domain과 패키지에 각각 있고 Data가 옮겨 담습니다. 중복처럼 보이지만 **그게 값입니다** — 나중에 CloudKit이나 원격 API로 바꿔도 Domain 위쪽은 손대지 않습니다. Repository를 처음부터 `async throws`로 둔 것도 같은 이유입니다. JSON 읽기는 즉시 끝나지만, 네트워크 구현이 들어올 때 시그니처가 바뀌면 UseCase·ViewModel까지 줄줄이 따라옵니다.

번들 JSON은 그때도 안 버립니다. 여행 앱은 데이터 로밍 안 되는 곳에서 켜지니 오프라인 폴백으로 남습니다.

## G 단계와 달라진 점

| | G (SwiftUI) | H (+ SPM) |
|---|---|---|
| 로컬 패키지 | — | **`Modules/TravelGuide`** |
| 새 기능 | — | **주요 관광 정보** (담아두기 → 시각 부여) |
| 새 도메인 | — | `RecommendedArea` · `RecommendedPlace` · `PlaceRecommendationRepository` · `RecommendAreasUseCase` |
| 일정 종류 | 장소·식사·숙소 | **+ 관광지**(시각 없는 장소) |
| 테스트 | 51 | **61 + 7**(패키지) |

## 테스트

| 대상 | 실행 | 개수 |
|---|---|---|
| **`TravelGuideTests`** | **`swift test`** (시뮬레이터 불필요) | **7** |
| `ObserveDayPlansUseCaseTests` | xcodebuild (시뮬레이터) | 10 |
| `ItineraryViewModelTests` | xcodebuild | 16 |
| `ItineraryEditorViewModelTests` | xcodebuild | 18 |
| 그 외 Domain·Presentation | xcodebuild | 17 |

## API 키 설정

AeroDataBox(RapidAPI) 키는 F부터 동일하게 `Secrets.local.xcconfig`로 주입합니다.

```
RAPIDAPI_KEY = your_rapidapi_key
```

## 빌드 · 테스트

Xcode 16+ / iOS 16.0+ / Swift 5.9+.

```
cd Modules/TravelGuide && swift test
```

```
xcodebuild test -project ProjectH.xcodeproj -scheme ProjectH -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

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
| **H** | **SPM 모듈화** |
| I | Micro Feature Architecture |
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
