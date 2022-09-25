#if swift(>=5.7) && (canImport(RegexBuilder))
  import Foundation
  import Object
  import RegexBuilder

  @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
  public enum TodoBuilder: TodoRegexable {
    public static func build(input: String) -> Todo {
      .init(
        id: .init(rawValue: UUID().uuidString),
        isCompletion: Completion.build(input: input),
        priority: Priority.build(input: input),
        title: Title.build(input: input),
        project: Project.build(input: input),
        context: Context.build(input: input),
        dueDate: DueDate.build(input: input)
      )
    }

    public static func build(inputs: [String]) -> TodoList {
      let todos = inputs.map(TodoBuilder.build(input:))
      return TodoList(todos)
    }
  }

  // MARK: - Completion

  extension TodoBuilder {
    enum Completion: TodoRegexable {
      static func build(input: String) -> Bool {
        let regex = Regex {
          Anchor.startOfLine
          "x"
          One(.whitespace)
        }

        return input.starts(with: regex)
      }
    }
  }

  // MARK: - Priority

  extension TodoBuilder {
    enum Priority: TodoRegexable {
      static func build(input: String) -> Todo.Priority? {
        let reference = Reference(Todo.Priority.self)
        let regex = Regex {
          ChoiceOf {
            One(.whitespace)
            Anchor.startOfLine
          }
          "("
          Capture(
            OneOrMore(.word), as: reference,
            transform: { word -> Todo.Priority in
              let string = String(word)
              return .init(string)
            })
          ")"
        }

        let match = input.firstMatch(of: regex)
        if let match {
          return match[reference]
        } else {
          return nil
        }
      }
    }
  }

  // MARK: - Title

  extension TodoBuilder {
    enum Title: TodoRegexable {
      static func build(input: String) -> String? {
        let reference = Reference(String.self)
        let regex = Regex {
          One(.whitespace)
          NegativeLookahead {
            "due:"
          }
          Capture(
            OneOrMore(.word), as: reference,
            transform: { word -> String in
              String(word)
            })
        }

        let match = input.firstMatch(of: regex)
        if let match {
          return match[reference]
        } else {
          return nil
        }
      }
    }
  }

  // MARK: - project

  extension TodoBuilder {
    enum Project: TodoRegexable {
      static func build(input: String) -> Todo.Project? {
        let reference = Reference(Todo.Project.self)
        let regex = Regex {
          ChoiceOf {
            One(.whitespace)
            Anchor.startOfLine
          }
          "+"
          Capture(
            OneOrMore(.word), as: reference,
            transform: { word -> Todo.Project in
              let string = String(word)
              return .init(string)
            })
        }

        let match = input.firstMatch(of: regex)
        if let match {
          return match[reference]
        } else {
          return nil
        }
      }
    }
  }

  // MARK: - context

  extension TodoBuilder {
    enum Context: TodoRegexable {
      static func build(input: String) -> Todo.Context? {
        let reference = Reference(Todo.Context.self)
        let regex = Regex {
          ChoiceOf {
            One(.whitespace)
            Anchor.startOfLine
          }
          "@"
          Capture(
            OneOrMore(.word), as: reference,
            transform: { word -> Todo.Context in
              let string = String(word)
              return .init(string)
            })
        }

        let match = input.firstMatch(of: regex)
        if let match {
          return match[reference]
        } else {
          return nil
        }
      }
    }
  }

  // MARK: - project

  extension TodoBuilder {
    enum DueDate: TodoRegexable {
      static func build(input: String) -> Date? {
        let reference = Reference(Date.self)
        let regex = Regex {
          ChoiceOf {
            One(.whitespace)
            Anchor.startOfLine
          }
          "due:"
          Capture(.iso8601Date(timeZone: .gmt), as: reference)
        }

        let match = input.firstMatch(of: regex)
        if let match {
          return match[reference]
        } else {
          return nil
        }
      }
    }
  }
#endif
