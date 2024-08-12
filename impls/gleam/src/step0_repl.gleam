import gleam/io
import gleam/iterator
import stdin.{stdin}

const prompt = "user> "

pub fn read(str: String) -> String {
  str
}

pub fn eval(ast: String, _env: String) -> String {
  ast
}

pub fn print(exp: String) -> String {
  exp
}

pub fn rep(str: String) -> String {
  read(str) |> eval("") |> print
}

pub fn main() {
  io.print(prompt)
  use line <- iterator.each(stdin())
  rep(line) |> io.print
  io.print(prompt)
}
