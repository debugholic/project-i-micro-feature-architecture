import SharedCommon

public protocol DeleteLodgingUseCase: UseCase where Request == Lodging, Response == Void {}
