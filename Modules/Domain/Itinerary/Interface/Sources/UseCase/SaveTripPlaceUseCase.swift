import SharedCommon

public protocol SaveTripPlaceUseCase: UseCase where Request == TripPlace, Response == Void {}
