pub type MalType {
  MalList(List(MalType))
  MalAtom(String)
  MalSymbol(String)
  MalNumber(Int)
}
