import XCTest

@testable import Todotxt

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
final class TodoBuilderTests: XCTestCase {
  func testBuildInput() {
    let input = "x (A) title +project @context due:2022-09-25"
    let todo = TodoBuilder.build(input: input)
    let output = todo.rawTodoTxt

    XCTAssertEqual(input, output)
  }

  func testBuildInputs() {
    let inputs = """
      x (A) title_1 +project @context due:2022-09-25
      (C) title_2 due:2022-09-26
      (B) title_3 +project due:2022-09-27
      (C) title_4 @context due:2022-09-28
      (A) title_5 due:2022-09-29
      """.components(separatedBy: "\n")
    let todoList = TodoBuilder.build(inputs: inputs)
    let outputs = todoList.value.map(\.rawTodoTxt)

    XCTAssertEqual(inputs, outputs)
  }
}
