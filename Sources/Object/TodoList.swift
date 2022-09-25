public struct TodoList: ExpressibleByArrayLiteral {
  public var value: [Todo]

  public init(_ value: [Todo]) {
    self.value = value
  }

  public init(arrayLiteral elements: Todo...) {
    self.init(elements)
  }
}

// MARK: - Sort

extension TodoList {
  public enum SortType {
    case dueDate
    case priority
    case project
    case context
  }

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
