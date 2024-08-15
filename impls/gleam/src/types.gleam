pub type MalType {
  MalList(List(MalType))
  MalSymbol(String)
  MalNumber(Int)
}
