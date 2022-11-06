/// Marker protocol for `String` to Todo object
public protocol TodoRegexable<Result> {
  associatedtype Result

  /// Create a `Result` object
  ///
  /// - Parameter input: todo.txt formated string
  /// - Returns: A return `Result` object
  static func build(input: String) -> Result
}
