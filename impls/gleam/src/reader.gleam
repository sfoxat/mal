import gleam/io
import gleam/regex

pub type Reader {
  Reader(tokens: List(String), position: Int)
}

pub fn tokenize(input: String) -> Nil {
  //Reader {
  let assert Ok(re) =
    regex.from_string(
      "[\\s,]*(~@|[\\[\\]{}()'`~^@]|\"(?:\\\\.|[^\\\\\"])*\"?|;.*|[^\\s\\[\\]{}('\"`,;)]*)",
    )

  io.debug(regex.scan(with: re, content: input))

  Nil
}

pub fn main() {
  tokenize("(+ 2 ass(* 3 4))")
}
