import SharedCommon

public protocol DeleteTripUseCase: UseCase where Request == Trip, Response == Void {}
