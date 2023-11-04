#if swift(>=5.7) && (canImport(RegexBuilder))
  import Foundation
  import Object
  import RegexBuilder
  import Markdown

  @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
  public enum TodoBuilder: TodoRegexable {
    public static func build(input: String) -> Todo {
      .init(
        id: .init(rawValue: UUID().uuidString),
        isCompletion: Completion.build(input: input),
        priority: Priority.build(input: input), dates: DateManagement.build(input: input),
        title: Title.build(input: input),
        projects: Project.build(input: input),
        contexts: Context.build(input: input),
        dueDate: DueDate.build(input: input),
        attributes: KeyValueAttributes.build(input: input)
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
          Anchor.startOfLine
          ZeroOrMore {
            ChoiceOf {
              One(.whitespace)
              One("x")
            }
          }
          "("
          Capture(
            OneOrMore((try? Regex("[A-Z]"))!), as: reference,
            transform: { word -> Todo.Priority in
              let string = String(word)
              return .init(string)
            })
          ") "
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
  struct LinkReplacer: MarkupRewriter {
    var foundLinks : [UUID:Link] = [:]
    mutating func visitLink(_ link: Link) -> Markup? {
      let linkUUID = UUID()
      foundLinks[linkUUID] = link
      return Text("link"+linkUUID.uuidString)
    }
  }

  extension TodoBuilder {
    enum Title: TodoRegexable {
      static func build(input: String) -> String? {
        let reference = Reference(String.self)
        let titlematch = OneOrMore {
          ChoiceOf {
            One(.whitespace)
            OneOrMore(.word)
            OneOrMore(.digit)
            OneOrMore(.anyOf("-_,;.\'\""))
          }
        }
        let regex = Regex {
          Anchor.startOfLine
          ZeroOrMore {
            ChoiceOf {
              One("x ")
              OneOrMore {
                "("
                (try? Regex("[A-Z]"))!
                ") "
              }
              One(.iso8601Date(timeZone: .gmt))
              One(.whitespace)
            }
          }
          Capture(titlematch, as: reference,
                  transform: { word -> String in String(word) })
          Lookahead {
            ChoiceOf {
              Anchor.endOfLine
              One(" +")
              One(" @")
              OneOrMore {
                One(.whitespace)
                OneOrMore(.word)
                One(":")
              }
            }
          }
        }
        
        // To capture markdown URLs we need to preprocess, replace them with a known word (uuid?), matche the rest, then re-replace them back
        var sanitized = input
        let document = Document(parsing: input)
        var linkDeleter = LinkReplacer()
        let newDocument = linkDeleter.visit(document)
        if !linkDeleter.foundLinks.isEmpty {
          sanitized = newDocument!.format()
        }
        
        let match = sanitized.firstMatch(of: regex)
        if let match {
          var result = match[reference].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) // because we sometimes capture the last space
          for deletedLink in linkDeleter.foundLinks {
            result = result.replacingOccurrences(of: "link"+deletedLink.key.uuidString, with: deletedLink.value.format())
          }
          
          return result
        } else {
          return nil
        }
      }
    }
  }

  // MARK: - project

  extension TodoBuilder {
    enum Project: TodoRegexable {
      static func build(input: String) -> [Todo.Project] {
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
        
        return input.matches(of: regex).map({ $0[reference] })
      }
    }
  }

  // MARK: - context

  extension TodoBuilder {
    enum Context: TodoRegexable {
      static func build(input: String) -> [Todo.Context] {
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
        
        return input.matches(of: regex).map({ $0[reference] })
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

  // MARK: - Key/Values

  extension TodoBuilder {
    enum KeyValueAttributes : TodoRegexable {
      static func build(input: String) -> [String:String] {
        let valuematch = ChoiceOf{
          OneOrMore(.word)
          OneOrMore(.digit)
          OneOrMore(.anyOf("-_,;."))
        }
        let key = Reference(String.self)
        let value = Reference(String.self)
        let regex : Regex = Regex {
          ChoiceOf {
            One(.whitespace)
            Anchor.startOfLine
          }
          Capture(OneOrMore(.word), as: key, transform: { String($0) }) // don't interpret it
          ":"
          Capture(OneOrMore(valuematch), as: value, transform: { String($0) })
        }
        
        var attrs : [String:String] = [:]
        for match in input.matches(of: regex) {
          if match[key] == "due" { continue }
          attrs[match[key]] = match[value]
        }
        return attrs
      }
    }
  }

  // MARK: - Optional dates like completed and created

  extension TodoBuilder {
    enum DateManagement : TodoRegexable {
      static func build(input: String) -> (Date,Date?)? {
        let reference = Reference(Date.self)
        let regex = Regex {
          ChoiceOf {
            One(.whitespace)
            Anchor.startOfLine
          }
          Capture(.iso8601Date(timeZone: .gmt), as: reference)
        }
        
        // must appear *before* the title
        var matches = input.matches(of: regex)
        if let title = TodoBuilder.Title.build(input: input), let tidx = input.firstMatch(of: title)?.range.lowerBound {
          matches = matches.filter({ match in
            match.range.lowerBound < tidx
          })
        }
        if matches.isEmpty { return nil } // no dates
        
        if matches.count == 1 { return (matches[0][reference],nil) } // if there's only one date, it's the creation date
        else if matches.count == 2 { return (matches[1][reference],matches[0][reference]) }
        else {
          fatalError("problem with dates")
        }
      }
    }
  }

#endif
