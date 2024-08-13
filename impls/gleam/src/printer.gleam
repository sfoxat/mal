import gleam/list
import gleam/string
import types.{type MalType, MalAtom, MalList}

pub fn pr_str(exp: MalType) -> String {
  case exp {
    MalAtom(name) -> name
    MalList(lst) -> {
      "("
      <> list.map(lst, pr_str)
      |> string.join(" ")
      <> ")"
    }
  }
}
