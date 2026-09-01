import SharedCommon

protocol RecommendAreasUseCase: UseCase where Request == String, Response == [RecommendedArea] {}
