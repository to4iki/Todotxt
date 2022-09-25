import Foundation

/// Todo for Todo.txt
///
/// - Note: e.g. `x (A) title +project @context due:yyyy-mm-dd`
/// - SeeAlso: https://github.com/todotxt/todo.txt
public struct Todo: Identifiable, TodoTxtRawRepresentable {
  public let id: ID
  public let isCompletion: Bool
  public let priority: Priority?
  public let title: String?
  public let project: Project?
  public let context: Context?
  public let dueDate: Date?

  public var rawTodoTxt: String {
    [
      completionRawTodoTxt,
      priority.map(\.rawTodoTxt),
      title,
      project.map(\.rawTodoTxt),
      context.map(\.rawTodoTxt),
      dueRawTodoTxt,
    ]
    .reduce(into: "") { (result, string) in
      if let string {
        result.append(" \(string)")
      }
    }
    .trimmingCharacters(in: .whitespaces)
  }

  private var completionRawTodoTxt: String? {
    isCompletion ? "x" : nil
  }

  private var dueRawTodoTxt: String? {
    dueDate.map { date in
      "due:\(Todo.dueDateFormatter.string(from: date))"
    }
  }

  public init(
    id: Todo.ID,
    isCompletion: Bool,
    priority: Todo.Priority?,
    title: String?,
    project: Todo.Project?,
    context: Todo.Context?,
    dueDate: Date?
  ) {
    self.id = id
    self.isCompletion = isCompletion
    self.priority = priority
    self.title = title
    self.project = project
    self.context = context
    self.dueDate = dueDate
  }
}

// MARK: - ID

extension Todo {
  public struct ID: Codable, ExpressibleByStringLiteral, Hashable, RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
      self.init(rawValue: value)
    }
  }
}

// MARK: - Priority

extension Todo {
  public struct Priority: Comparable, TodoTxtRawRepresentable {
    public let value: String

    public var rawTodoTxt: String {
      "(\(value))"
    }

    public init(_ string: String) {
      self.value = string
    }

    public static func < (lhs: Todo.Priority, rhs: Todo.Priority) -> Bool {
      lhs.value < rhs.value
    }
  }
}

// MARK: - Project

extension Todo {
  public struct Project: Comparable, TodoTxtRawRepresentable {
    public let title: String

    public var rawTodoTxt: String {
      "+\(title)"
    }

    public init(_ title: String) {
      self.title = title
    }

    public static func < (lhs: Todo.Project, rhs: Todo.Project) -> Bool {
      lhs.title < rhs.title
    }
  }
}

// MARK: - Context

extension Todo {
  public struct Context: Comparable, TodoTxtRawRepresentable {
    public let title: String

    public var rawTodoTxt: String {
      "@\(title)"
    }

    public init(_ title: String) {
      self.title = title
    }

    public static func < (lhs: Todo.Context, rhs: Todo.Context) -> Bool {
      lhs.title < rhs.title
    }
  }
}

// MARK: - DateFormatter

extension Todo {
  private static let dueDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = NSLocale.current
    return formatter
  }()
}
