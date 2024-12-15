import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import simplifile as file

pub fn solve() {
  file.read("/Users/gtruitt/Downloads/advent-2024-day-01.txt")
  |> result.unwrap("")
  |> string.trim
  |> string.split("\n")
  |> list.map(string.split(_, "   "))
  |> list.transpose
  |> fn(l) {
    case l {
      [x, y] -> #(x, y)
      _ -> #([], [])
    }
  }
  |> fn(p) { #(list.map(p.0, to_int), list.map(p.1, to_int)) }
  |> fn(p) { #(p.0, list.fold(p.1, dict.new(), increment)) }
  |> fn(p) { list.fold(p.0, 0, fn(acc, val) { acc_multiple(acc, val, p.1) }) }
  |> io.debug
}

fn to_int(s: String) {
  case int.parse(s) {
    Ok(i) -> i
    Error(_) -> 0
  }
}

fn increment(d: dict.Dict(a, Int), key: a) {
  dict.upsert(d, key, fn(x) {
    case x {
      option.Some(i) -> i + 1
      option.None -> 1
    }
  })
}

fn acc_multiple(acc: Int, val: Int, lookup: dict.Dict(Int, Int)) {
  case dict.get(lookup, val) {
    Ok(i) -> i
    Error(_) -> 0
  }
  |> int.multiply(val)
  |> int.add(acc)
}
