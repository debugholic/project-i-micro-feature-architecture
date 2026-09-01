import SharedCommon

public protocol SaveItineraryItemUseCase: UseCase where Request == ItineraryItem, Response == Void {}
