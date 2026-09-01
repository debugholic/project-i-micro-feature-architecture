import Combine
import SharedCommon

protocol ObserveDayPlansUseCase: UseCase where Request == Trip, Response == AnyPublisher<[DayPlan], Never> {}
