public protocol TodoRegexable<Result> {
  associatedtype Result
  static func build(input: String) -> Result
}
