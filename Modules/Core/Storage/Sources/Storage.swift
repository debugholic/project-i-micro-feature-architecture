import Combine

/// 값의 목록을 들고 변화를 방출하는 저장소. 구현이 메모리인지 디스크인지 소비자는 알지 않는다.
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
