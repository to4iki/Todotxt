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
    
    func testBuildInputWithKeys() {
        let input = "x (A) title +project @context due:2022-09-25 id:17 foo:bar tags:bla,bli,blu"
        let todo = TodoBuilder.build(input: input)
        let id = todo["id"]
        let foo = todo["foo"]
        let tags = todo["tags"]
        
        XCTAssertEqual(id, "17")
        XCTAssertEqual(foo, "bar")
        XCTAssertEqual(tags, "bla,bli,blu")
        
        let rawOut = todo.rawTodoTxt
        // no guarantee for the order of the keys
        XCTAssert(rawOut.contains("id:17"))
        XCTAssert(rawOut.contains("foo:bar"))
        XCTAssert(rawOut.contains("tags:bla,bli,blu"))
    }
    
    func testBuildCompletedInputWithKeys() {
        let input = "x (A) 2022-09-26 title +project @context due:2022-09-25 id:17 foo:bar tags:bla,bli,blu"
        let todo = TodoBuilder.build(input: input)
        let id = todo["id"]
        let foo = todo["foo"]
        let tags = todo["tags"]
        
        XCTAssertEqual(id, "17")
        XCTAssertEqual(foo, "bar")
        XCTAssertEqual(tags, "bla,bli,blu")
        
        let rawOut = todo.rawTodoTxt
        // no guarantee for the order of the keys
        XCTAssert(rawOut.contains("id:17"))
        XCTAssert(rawOut.contains("foo:bar"))
        XCTAssert(rawOut.contains("tags:bla,bli,blu"))
    }
    
}
