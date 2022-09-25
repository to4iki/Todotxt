# Todotxt

[![CI](https://github.com/to4iki/TodoTxt/actions/workflows/ci.yml/badge.svg)](https://github.com/to4iki/TodoTxt/actions/workflows/ci.yml)
![Swift 5](https://img.shields.io/badge/swift-5-orange.svg)
![MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg)

parser of todo.txt format

https://github.com/todotxt/todo.txt

## Usage
build [Todo](./Sources/Object/Todo.swift) object

```swift
let input = "x (A) title +project @context due:2022-09-25"
let todo = TodoBuilder.build(input: input)
```

### Sorted
sort [TodoList](./Sources/Object/TodoList.swift) in order of `TodoList.SortType`

```swift
extension TodoList {
  public enum SortType {
    case dueDate
    case priority
    case project
    case context
  }
}

let inputs = """
  x (A) title_1 +project @context due:2022-09-25
  (C) title_2 due:2022-09-26
  (B) title_3 +project due:2022-09-27
  (C) title_4 @context due:2022-09-28
  (A) title_5 due:2022-09-29
""".components(separatedBy: "\n")

let todoList = TodoBuilder.build(inputs: inputs)
todoList.sorted(by: .priority).value.map(\.title)
// title_1, title_5, title_3, title_2, title_4
```

## License

Todotxt is released under the MIT license.
