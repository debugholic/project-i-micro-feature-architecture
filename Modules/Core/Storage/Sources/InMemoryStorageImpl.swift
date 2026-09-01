import Combine

/// 프로세스 수명 동안만 유지되는 저장소. 영속화가 들어오기 전까지의 기본 구현이다.
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

  /// 같은 `id` 가 있으면 교체하고 없으면 덧붙인다.
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
