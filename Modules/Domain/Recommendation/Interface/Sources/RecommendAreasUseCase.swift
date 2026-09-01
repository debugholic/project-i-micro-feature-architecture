import SharedCommon

public protocol RecommendAreasUseCase: UseCase where Request == String, Response == [RecommendedArea] {}
