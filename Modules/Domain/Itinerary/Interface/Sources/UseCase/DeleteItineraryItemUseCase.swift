import SharedCommon

public protocol DeleteItineraryItemUseCase: UseCase where Request == ItineraryItem, Response == Void {}
