public nonisolated struct Movement: Codable, Hashable {
  public let airport: Airport
  public let scheduledTime: ScheduledTime

  public init(
    airport: Airport,
    scheduledTime: ScheduledTime
  ) {
    self.airport = airport
    self.scheduledTime = scheduledTime
  }
}
