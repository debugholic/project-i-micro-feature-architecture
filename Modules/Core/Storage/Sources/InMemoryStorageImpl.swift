import Combine

public final class InMemoryStorageImpl<Element: Identifiable>: Storage {
  @Published private var elements: [Element] = []

  public var elementsPublisher: AnyPublisher<[Element], Never> {
    $elements.eraseToAnyPublisher()
  }

  public init(
    elements: [Element] = []
  ) {
    self.elements = elements
  }

  public func save(
    _ element: Element
  ) {
    guard let index = elements.firstIndex(
      where: { $0.id == element.id }
    ) else {
      elements.append(element)
      return
    }
    elements[index] = element
  }

  public func delete(
    _ element: Element
  ) {
    elements.removeAll {
      $0.id == element.id
    }
  }
}
