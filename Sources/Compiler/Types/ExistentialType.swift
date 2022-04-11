/// An existential type, optionally bound by traits and constraints on associated types.
public struct ExistentialType: TypeProtocol, Hashable {

  /// The traits to which the witness is known to conform.
  public let traits: Set<TraitType>

  /// The constraints on the associated types of the witness.
  ///
  /// - Note: This set shall only contain equality and conformance constraints.
  public let constraints: Set<TypeConstraint>

  public let flags: TypeFlags

  /// Creates a new existential type bound by the given traits and constraints.
  public init<S: Sequence>(
    traits: Set<TraitType>,
    constraints: S
  ) where S.Element == TypeConstraint {
    self.traits = traits

    var cs: Set<TypeConstraint> = []
    cs.reserveCapacity(constraints.underestimatedCount)
    for c in constraints {
      switch c {
      case .equality, .conformance:
        cs.insert(c)
      default:
        preconditionFailure("type may only be contained by equality or conformance")
      }
    }
    self.constraints = cs

    let flags = traits.reduce(into: TypeFlags.isCanonical, { (a, b) in a.merge(b.flags) })
    self.flags = flags // FIXME
  }

  public func canonical() -> Type {
    .existential(ExistentialType(
      traits: traits, constraints: Set(constraints.map({ $0.canonical() }))))
  }

}
