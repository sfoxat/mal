import gleam/io
import gleam/iterator
import gleam/result
import printer
import reader
import stdin.{stdin}
import types.{type MalError, type MalType}

const prompt = "user> "

pub fn read(str: String) -> Result(MalType, MalError) {
  reader.read_str(str)
}

pub fn eval(ast: MalType, _env: String) -> Result(MalType, MalError) {
  Ok(ast)
}

pub fn print(ast: MalType) -> String {
  printer.pr_str(ast) <> "\n"
}

pub fn rep(str: String) -> String {
  case result.then(read(str), eval(_, "")) {
    Ok(ast) -> print(ast)
    Error(types.ErrEof) -> ""
    Error(types.ErrMsg(msg)) -> msg <> "\n"
  }
}

pub fn main() {
  io.print(prompt)
  use line <- iterator.each(stdin())
  rep(line) |> io.print
  io.print(prompt)
}
