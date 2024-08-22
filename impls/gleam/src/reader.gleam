import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/regex
import gleam/result
import gleam/string
import types.{type MalError, type MalType, MalList, MalNumber, MalSymbol}

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

pub fn next(reader: Reader) -> Result(#(Token, Reader), MalError) {
  case reader.tokens {
    [] -> Error(types.ErrEof)
    [first, ..rest] -> Ok(#(first, Reader(rest)))
  }
}

pub fn peek(reader: Reader) -> Result(Token, MalError) {
  case reader.tokens {
    [] -> Error(types.ErrEof)
    [first, ..] -> Ok(first)
  }
}

pub fn skip(reader: Reader) -> Result(Reader, MalError) {
  next(reader) |> result.map(with: pair.second)
}

pub fn read_str(input: String) -> Result(MalType, MalError) {
  read_form(tokenize(input))
  |> result.map(pair.first)
}

pub fn read_form(reader: Reader) -> Result(#(MalType, Reader), MalError) {
  use token <- result.try(peek(reader))
  case token {
    "(" -> read_list(reader)
    _ -> read_atom(reader)
  }
}

pub fn read_list(reader: Reader) -> Result(#(MalType, Reader), MalError) {
  use reader <- result.try(skip(reader))
  case do_read_list(reader, []) {
    Ok(#(lst, reader)) -> Ok(#(MalList(list.reverse(lst)), reader))
    Error(types.ErrEof) -> Error(types.ErrMsg("error:reader:unbalanced parens"))
    Error(err) -> Error(err)
  }
}

fn do_read_list(
  reader: Reader,
  acc: List(MalType),
) -> Result(#(List(MalType), Reader), MalError) {
  use token <- result.try(peek(reader))
  case token {
    ")" -> skip(reader) |> result.map(pair.new(acc, _))
    _ -> {
      use #(form, reader) <- result.try(read_form(reader))
      do_read_list(reader, [form, ..acc])
    }
  }
}

pub fn read_atom(reader: Reader) -> Result(#(MalType, Reader), MalError) {
  use #(token, reader) <- result.try(next(reader))
  [parse_comment, parse_number, parse_symbol]
  |> do_read_atom(token)
  |> result.map(pair.new(_, reader))
}

type AtomParser =
  fn(Token) -> Result(Option(MalType), MalError)

fn do_read_atom(
  parsers: List(AtomParser),
  token: Token,
) -> Result(MalType, MalError) {
  case parsers {
    [] -> Error(types.ErrMsg("error:reader:can't parse atom"))
    [parser, ..rest] -> {
      case parser(token) {
        Error(err) -> Error(err)
        Ok(None) -> do_read_atom(rest, token)
        Ok(Some(mal_type)) -> Ok(mal_type)
      }
    }
  }
}

pub fn parse_comment(token: Token) -> Result(Option(MalType), MalError) {
  case string.first(token) {
    Ok(";") -> Error(types.ErrEof)
    _ -> Ok(None)
  }
}

pub fn parse_number(token: Token) -> Result(Option(MalType), MalError) {
  case string.pop_grapheme(token) {
    Ok(#("-", rest)) ->
      parse_int_part(rest) |> result.map(option.map(_, int.negate))
    Ok(#("+", rest)) -> parse_int_part(rest)
    _ -> parse_int_part(token)
  }
  |> result.map(option.map(_, MalNumber))
}

fn parse_int_part(token: Token) -> Result(Option(Int), MalError) {
  case string.first(token) {
    Ok(first) ->
      case first {
        "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ->
          int.parse(token)
          |> result.map(Some)
          |> result.map_error(fn(_) {
            types.ErrMsg("error:reader:not a number")
          })
        _ -> Ok(None)
      }
    Error(_) -> Ok(None)
  }
}

pub fn parse_symbol(token: Token) -> Result(Option(MalType), MalError) {
  Ok(Some(MalSymbol(token)))
}

pub fn main() {
  read_str("(+ 2 ass(* 3 4))") |> io.debug
}
