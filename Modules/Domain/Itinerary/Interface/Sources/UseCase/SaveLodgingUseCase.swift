import SharedCommon

public protocol SaveLodgingUseCase: UseCase where Request == Lodging, Response == Void {}
