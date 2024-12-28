import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile as file

pub fn solve() {
  file.read("example_data/day_07")
  |> result.unwrap("")
  |> string.trim
  |> string.split("\n")
  |> list.map(string.split(_, ": "))
  |> list.map(fn(equation) {
    case equation {
      [rhs, terms] -> #(
        string.split(terms, " ") |> list.map(to_int),
        to_int(rhs),
      )
      _ -> panic
    }
  })
  |> list.map(fn(e) { balance(e.0, e.1) })
  |> int.sum
  |> io.debug
  // expecting 11387
}

fn to_int(s: String) {
  case int.parse(s) {
    Ok(i) -> i
    _ -> panic
  }
}

fn balance(terms: List(Int), rhs: Int) -> Int {
  case terms {
    [a] -> bool.to_int(a == rhs)
    [a, b] ->
      case
        balance([a * b], rhs)
        + balance([a + b], rhs)
        + balance([to_int(int.to_string(a) <> int.to_string(b))], rhs)
      {
        0 -> 0
        _ -> rhs
      }
    [a, b, ..rest] ->
      case
        balance([a * b, ..rest], rhs)
        + balance([a + b, ..rest], rhs)
        + balance([to_int(int.to_string(a) <> int.to_string(b)), ..rest], rhs)
      {
        0 -> 0
        _ -> rhs
      }
    _ -> panic
  }
}
