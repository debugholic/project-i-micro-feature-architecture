import Combine
import Foundation

/// `UserDefaults` 에 JSON 으로 영속화하는 저장소. 앱을 껐다 켜도 값이 남는다.
public final class UserDefaultsStorageImpl<Element: Codable & Identifiable>: Storage {
  private let defaults: UserDefaults
  private let encoder = JSONEncoder()
  private let key: String
  private let subject: CurrentValueSubject<[Element], Never>

  public var elementsPublisher: AnyPublisher<[Element], Never> {
    subject.eraseToAnyPublisher()
  }

  public init(
    defaults: UserDefaults = .standard,
    key: String
  ) {
    self.defaults = defaults
    self.key = key
    self.subject = CurrentValueSubject(
      defaults.data(
        forKey: key
      ).flatMap {
        try? JSONDecoder().decode([Element].self, from: $0)
      } ?? []
    )
  }

  /// 같은 `id` 가 있으면 교체하고 없으면 덧붙인다.
  public func save(
    _ element: Element
  ) {
    var elements = subject.value

    guard let index = elements.firstIndex(
      where: { $0.id == element.id }
    ) else {
      elements.append(element)
      persist(elements)
      return
    }
    elements[index] = element
    persist(elements)
  }

  public func delete(
    _ element: Element
  ) {
    persist(
      subject.value.filter { $0.id != element.id }
    )
  }

  private func persist(
    _ elements: [Element]
  ) {
    guard let data = try? encoder.encode(elements) else { return }
    defaults.set(data, forKey: key)
    subject.send(elements)
  }
}
