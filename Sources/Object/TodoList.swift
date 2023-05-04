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
      return _sorted(by: \.project)
    case .context:
      return _sorted(by: \.context)
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
}
