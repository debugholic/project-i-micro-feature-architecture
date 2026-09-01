import Foundation
import SharedCommon

nonisolated struct CreateTripRequest {
  let outboundDate: Date
  let outboundNumber: String
  let returnDate: Date?
  let returnNumber: String?
}

protocol CreateTripUseCase: UseCase where Request == CreateTripRequest, Response == Void {}
