public protocol ViewModelActions {}
public protocol ViewModelInput {}
public protocol ViewModelOutput {}

extension Never: ViewModelActions {}

public protocol ViewModel: ViewModelInput, ViewModelOutput {
  associatedtype Actions: ViewModelActions = Never

  var actions: Actions? { get }
}

extension ViewModel where Actions == Never {
  public var actions: Actions? { nil }
}
