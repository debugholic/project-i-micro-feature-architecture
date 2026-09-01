import Combine
import Foundation
import SharedCommon

public protocol ObserveDayPlansUseCase: UseCase
where Request == UUID, Response == AnyPublisher<[DayPlan], Never> {}
