import gleam/int
import gleam/list
import gleam/string
import types.{type MalType, MalList, MalNumber, MalSymbol}

pub fn pr_str(exp: MalType) -> String {
  case exp {
    MalList(lst) -> {
      "("
      <> list.map(lst, pr_str)
      |> string.join(" ")
      <> ")"
    }
    MalSymbol(name) -> name
    MalNumber(number) -> int.to_string(number)
  }
}
