import Foundation

public nonisolated enum AppConfig {
  public static var rapidAPIKey: String {
    (
      Bundle.main.object(
        forInfoDictionaryKey: "RapidAPIKey"
      ) as? String
    ) ?? ""
  }
}
