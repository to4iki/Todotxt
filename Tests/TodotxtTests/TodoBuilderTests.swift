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
      2022-09-25 date1 due:2022-09-20
      x 2022-09-25 date2 due:2022-09-20
      (A) 2022-09-25 date3 due:2022-09-20
      x (A) 2022-09-25 date4 due:2022-09-20
      2022-09-25 2022-09-15 date5 due:2022-09-20
      x 2022-09-25 2022-09-15 date6 due:2022-09-20
      (A) 2022-09-25 2022-09-15 date7 due:2022-09-20
      x (A) 2022-09-25 2022-09-15 date8 due:2022-09-20
      x (A) 2022-09-25 2022-09-15 date8 tag:2022-09-20
      something
      something @context
      something +project
      """.components(separatedBy: "\n")
    let todoList = TodoBuilder.build(inputs: inputs)
    let outputs = todoList.value.map(\.rawTodoTxt)
    
    for idx in 0..<inputs.count {
      XCTAssertEqual(inputs[idx], outputs[idx], "error with line \(idx): \(inputs[idx])")
    }
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
  
  // Canonical examples from https://github.com/todotxt/todo.txt
  func testCanonical1() {
    let ex1 = TodoBuilder.build(input: "x (A) 2016-05-20 2016-04-30 measure space for +chapelShelving @chapel due:2016-05-30")
    XCTAssertTrue(ex1.isCompletion)
    XCTAssertEqual(ex1.priority?.value,"A")
    XCTAssertEqual(ex1.createdAt, DateComponents(calendar: Calendar.current, timeZone: .gmt, year: 2016, month: 4, day: 30).date)
    XCTAssertEqual(ex1.completedAt, DateComponents(calendar: Calendar.current, timeZone: .gmt, year: 2016, month: 5, day: 20).date)
    XCTAssertEqual(ex1.title, "measure space for")
    XCTAssertEqual(ex1.project?.title, "chapelShelving")
    XCTAssertEqual(ex1.context?.title, "chapel")
    XCTAssertEqual(ex1.dueDate, DateComponents(calendar: Calendar.current, timeZone: .gmt, year: 2016, month: 5, day: 30).date)
    
    // Incomplete Tasks: Format Rule 1
    let ex2 = TodoBuilder.build(inputs:"""
(A) Call Mom
Really gotta call Mom (A) @phone @someday
(b) Get back to the boss
(B)->Submit TPS report
""".components(separatedBy: CharacterSet.newlines))
    XCTAssertEqual(ex2.value[0].priority?.value, "A")
    XCTAssertNil(ex2.value[1].priority)
    XCTAssertNil(ex2.value[2].priority)
    XCTAssertNil(ex2.value[3].priority)
    
    // Incomplete Tasks: Format Rule 2
    let ex3 = TodoBuilder.build(inputs:"""
2011-03-02 Document +TodoTxt task format
(A) 2011-03-02 Call Mom
(A) Call Mom 2011-03-02
""".components(separatedBy: CharacterSet.newlines))
    XCTAssertNotNil(ex3.value[0].createdAt)
    XCTAssertNotNil(ex3.value[1].createdAt)
    XCTAssertNil(ex3.value[2].createdAt)
    
    // Incomplete Tasks: Format Rule 3
    let exm = TodoBuilder.build(inputs:"""
(A) Call Mom +Family +PeaceLoveAndHappiness @iphone @phone
Email SoAndSo at soandso@example.com
Learn how to add 2+2
""".components(separatedBy: CharacterSet.newlines))
    XCTAssertNotNil(exm.value[0].context) // TODO: multiple
    XCTAssertNil(exm.value[1].context)
    XCTAssertNil(exm.value[2].context)
  }
    
  func testCanonical2() {
    // Complete Tasks: Format Rule 1
    let ex4 = TodoBuilder.build(inputs:"""
x 2011-03-03 Call Mom
xylophone lesson
X 2012-01-01 Make resolutions
(A) x Find ticket prices
""".components(separatedBy: CharacterSet.newlines))
    XCTAssertTrue(ex4.value[0].isCompletion)
    XCTAssertFalse(ex4.value[1].isCompletion)
    XCTAssertFalse(ex4.value[2].isCompletion)
    XCTAssertFalse(ex4.value[3].isCompletion)
    
    // Complete Tasks: Format Rule 2
    let ex5 = TodoBuilder.build(input: "x 2011-03-02 2011-03-01 Review Tim's pull request +TodoTxtTouch @github")
    XCTAssertTrue(ex5.isCompletion)
    XCTAssertEqual(ex5.createdAt, DateComponents(calendar: Calendar.current, timeZone: .gmt, year: 2011, month: 3, day: 1).date)
    XCTAssertEqual(ex5.completedAt, DateComponents(calendar: Calendar.current, timeZone: .gmt, year: 2011, month: 3, day: 2).date)
  }
}
