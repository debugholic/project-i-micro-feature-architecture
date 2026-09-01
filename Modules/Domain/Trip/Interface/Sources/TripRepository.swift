/// 읽기는 `Storage` 의 Publisher 가 직접 담당하므로 쓰기만 정의한다.
public protocol TripRepository {
  func save(
    _ trip: Trip
  )

  func remove(
    _ trip: Trip
  )
}
