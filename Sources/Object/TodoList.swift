/// Objects corresponding to one line of Todo.txt file
public struct TodoList: ExpressibleByArrayLiteral, Sequence {
  public var value: [Todo]
  
  public init(_ value: [Todo]) {
    self.value = value
  }
  
  public init(arrayLiteral elements: Todo...) {
    self.init(elements)
  }
  
  public func makeIterator() -> TodoListIterator {
    TodoListIterator(self)
  }
}

// MARK: - IteratorProtocol

public struct TodoListIterator: IteratorProtocol {
  public typealias Element = Todo
  
  private let list: TodoList
  private var index: Int = 0
  
  fileprivate init(_ _todoList: TodoList) {
    self.list = _todoList
  }
  
  public mutating func next() -> Element? {
    defer { index += 1 }
    guard index < list.value.count else {
      return nil
    }
    return list.value[index]
  }
}

// MARK: - Sort

extension TodoList {
  /// ``Todo`` object property type.
  public enum SortType {
    case dueDate
    case priority
    case project
    case context
  }
  
  /// Sort by ``Todo`` object property.
  ///
  /// - Parameter type: sorting key type.
  /// - Returns: A sorted array of the sequence’s elements ``TodoList``.
  public func sorted(by type: SortType) -> TodoList {
    switch type {
    case .dueDate:
      return _sorted(by: \.dueDate)
    case .priority:
      return _sorted(by: \.priority)
    case .project:
      return _sorted(by: \.projects)
    case .context:
      return _sorted(by: \.contexts)
    }
  }
  
  /// - Note: default order: *ascending*
  private func _sorted<T: Comparable>(by keyPath: KeyPath<Todo, T?>) -> TodoList {
    let sortedValue = value.sorted { lhs, rhs in
      switch (lhs[keyPath: keyPath], rhs[keyPath: keyPath]) {
      case let (.some(l), .some(r)):
        return l < r
      case (.some, nil):
        return true
      case (nil, .some):
        return false
      case (nil, nil):
        return false
      }
    }
    return .init(sortedValue)
  }
  
  /// Sorting by collection doesn't work by default. We use the first in alphabetical order
  private func _sorted(by keyPath: KeyPath<Todo, Array<Todo.Context>>) -> TodoList {
    return .init(value.sorted(by: { t1, t2 in t1.contexts < t2.contexts }))
  }
  
  private func _sorted(by keyPath: KeyPath<Todo, Array<Todo.Project>>) -> TodoList {
    return .init(value.sorted(by: { t1, t2 in t1.projects < t2.projects }))
  }
  
}

/// Sorting by collection doesn't work by default. We use the first in alphabetical order
extension Array : Comparable where Element == Todo.Context {
  public static func < (lhs: Array<Element>, rhs: Array<Element>) -> Bool {
    if lhs.isEmpty { return false }
    else if lhs.isEmpty { return true }
    else { return lhs.sorted().first! < rhs.sorted().first! }
  }
}

extension Array where Element == Todo.Project {
  public static func < (lhs: Array<Element>, rhs: Array<Element>) -> Bool {
    if lhs.isEmpty { return false }
    else if lhs.isEmpty { return true }
    else { return lhs.sorted().first! < rhs.sorted().first! }
  }
}
