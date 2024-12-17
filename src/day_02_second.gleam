import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile as file

pub fn solve() {
  file.read("example_data/day_02")
  |> result.unwrap("")
  |> string.trim
  |> string.split("\n")
  |> list.map(string.split(_, " "))
  |> list.map(list.map(_, string_to_int))
  |> list.map(is_safe)
  |> list.map(bool.to_int)
  |> int.sum
  |> io.debug
  // expecting 4
}

fn is_safe(l: List(Int)) {
  is_safe_loop([], l, fn(a, b) { a > b }, 0)
  || is_safe_loop([], l, fn(a, b) { a < b }, 0)
}

fn is_safe_loop(
  left: List(Int),
  right: List(Int),
  comparator: fn(Int, Int) -> Bool,
  damping: Int,
) {
  let first_left = result.unwrap(list.first(left), 0)
  let rest_left = result.unwrap(list.rest(left), [])
  let first_right = result.unwrap(list.first(right), 0)
  let rest_right = result.unwrap(list.rest(right), [])

  case left, right {
    [], _ -> is_safe_loop([first_right], rest_right, comparator, damping)
    _, [] ->
      list.length(left) >= list.length(left) + list.length(right) - 1
      && damping < 2
    _, _ ->
      {
        comparator(first_left, first_right)
        && has_safe_magnitude(#(first_left, first_right))
        && is_safe_loop([first_right, ..left], rest_right, comparator, damping)
      }
      || is_safe_loop(left, rest_right, comparator, damping + 1)
      || is_safe_loop(rest_left, right, comparator, damping + 1)
  }
}

fn string_to_int(s: String) {
  result.unwrap(int.parse(s), 0)
}

fn has_safe_magnitude(window: #(Int, Int)) {
  int.subtract(window.0, window.1)
  |> int.absolute_value
  < 4
}
