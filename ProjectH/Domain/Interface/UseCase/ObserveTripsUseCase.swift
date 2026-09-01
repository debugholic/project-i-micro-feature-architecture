import Combine
import SharedCommon

protocol ObserveTripsUseCase: UseCase where Request == Void, Response == AnyPublisher<[Trip], Never> {}
