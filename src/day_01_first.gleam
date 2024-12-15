import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile as file

pub fn solve() {
  file.read("example_data/day_01")
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
  |> fn(p) { #(list.sort(p.0, int.compare), list.sort(p.1, int.compare)) }
  |> fn(p) { list.map2(p.0, p.1, fn(a, b) { int.absolute_value(a - b) }) }
  |> int.sum
  |> io.debug
  // expecting 11
}

fn to_int(s: String) {
  result.unwrap(int.parse(s), 0)
}
