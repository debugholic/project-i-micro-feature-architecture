import SharedCommon

protocol DeleteTripUseCase: UseCase where Request == Trip, Response == Void {}
