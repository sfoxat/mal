pub type MalType {
  MalList(List(MalType))
  MalSymbol(String)
  MalNumber(Int)
}

pub type MalError {
  ErrEof
  ErrMsg(String)
}
