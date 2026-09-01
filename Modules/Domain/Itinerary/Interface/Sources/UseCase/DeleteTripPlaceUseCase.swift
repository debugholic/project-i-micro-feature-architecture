import SharedCommon

public protocol DeleteTripPlaceUseCase: UseCase where Request == TripPlace, Response == Void {}
