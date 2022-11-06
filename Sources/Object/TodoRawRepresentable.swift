/// Marker protocol for Todo object to `String`
public protocol TodoRawRepresentable {
  /// A return raw todo.txt formated `String`
  var rawTodoTxt: String { get }
}
