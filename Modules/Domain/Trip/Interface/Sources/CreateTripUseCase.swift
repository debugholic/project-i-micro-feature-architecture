import Foundation
import SharedCommon

public nonisolated struct CreateTripRequest {
  public let outboundDate: Date
  public let outboundNumber: String
  public let returnDate: Date?
  public let returnNumber: String?

  public init(
    outboundDate: Date,
    outboundNumber: String,
    returnDate: Date?,
    returnNumber: String?
  ) {
    self.outboundDate = outboundDate
    self.outboundNumber = outboundNumber
    self.returnDate = returnDate
    self.returnNumber = returnNumber
  }
}

public protocol CreateTripUseCase: UseCase where Request == CreateTripRequest, Response == Void {}
