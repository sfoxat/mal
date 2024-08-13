import gleam/io
import gleam/list
import gleam/option
import gleam/pair
import gleam/regex
import gleam/result
import types.{type MalType, MalAtom, MalList}

pub type Token =
  String

pub type Reader {
  Reader(tokens: List(Token))
}

pub fn tokenize(input: String) -> Reader {
  let assert Ok(re) =
    regex.from_string(
      "[\\s,]*(~@|[\\[\\]{}()'`~^@]|\"(?:\\\\.|[^\\\\\"])*\"?|;.*|[^\\s\\[\\]{}('\"`,;)]*)",
    )

  let tokens =
    regex.scan(with: re, content: input)
    |> list.flat_map(with: fn(match) { match.submatches |> option.values() })

  Reader(tokens)
}

pub fn next(reader: Reader) -> Result(#(Token, Reader), Nil) {
  case reader.tokens {
    [] -> Error(Nil)
    [first, ..rest] -> Ok(#(first, Reader(rest)))
  }
}

pub fn peek(reader: Reader) -> Result(Token, Nil) {
  case reader.tokens {
    [] -> Error(Nil)
    [first, ..] -> Ok(first)
  }
}

fn skip(reader: Reader) -> Result(Reader, Nil) {
  next(reader) |> result.map(with: pair.second)
}

pub fn read_str(input: String) {
  read_form(tokenize(input))
}

pub fn read_form(reader: Reader) -> Result(#(MalType, Reader), Nil) {
  use token <- result.try(peek(reader))
  case token {
    "(" -> read_list(reader)
    _ -> read_atom(reader)
  }
}

pub fn read_list(reader: Reader) -> Result(#(MalType, Reader), Nil) {
  use reader <- result.try(skip(reader))
  use #(lst, reader) <- result.try(do_read_list(reader, []))
  Ok(#(MalList(list.reverse(lst)), reader))
}

fn do_read_list(
  reader: Reader,
  acc: List(MalType),
) -> Result(#(List(MalType), Reader), Nil) {
  use token <- result.try(peek(reader))
  case token {
    ")" -> skip(reader) |> result.map(pair.new(acc, _))
    _ -> {
      use #(form, reader) <- result.try(read_form(reader))
      do_read_list(reader, [form, ..acc])
    }
  }
}

pub fn read_atom(reader: Reader) -> Result(#(MalType, Reader), Nil) {
  use #(token, reader) <- result.try(next(reader))
  Ok(#(MalAtom(token), reader))
}

pub fn main() {
  read_str("(+ 2 ass(* 3 4))") |> io.debug
}
