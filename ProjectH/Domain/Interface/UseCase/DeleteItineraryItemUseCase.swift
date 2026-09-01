import SharedCommon

protocol DeleteItineraryItemUseCase: UseCase where Request == ItineraryItem, Response == Void {}
