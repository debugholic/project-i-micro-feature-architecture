import DomainReservationInterface

/// 항공 도메인 값의 표시 문자열. 다른 모듈도 공항명을 같은 규칙으로 보여준다.
public nonisolated enum ReservationFormatter {
  private static let unknownCity = "도착지"

  public static func cityName(
    _ airport: Airport
  ) -> String {
    airport.city ?? airport.code ?? unknownCity
  }
}
