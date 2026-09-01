import Combine

public protocol Storage<Element> {
  associatedtype Element: Identifiable

  var elementsPublisher: AnyPublisher<[Element], Never> { get }

  func save(
    _ element: Element
  )

  func delete(
    _ element: Element
  )
}
