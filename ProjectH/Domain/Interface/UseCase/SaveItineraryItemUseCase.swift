import SharedCommon

protocol SaveItineraryItemUseCase: UseCase where Request == ItineraryItem, Response == Void {}
