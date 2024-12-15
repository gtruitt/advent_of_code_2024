import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile as file

pub fn solve() {
  file.read("/Users/gtruitt/Downloads/advent-2024-day-02.txt")
  |> result.unwrap("")
  |> string.trim
  |> string.split("\n")
  |> list.map(string.split(_, " "))
  |> list.map(list.map(_, to_int))
  |> list.map(is_safe)
  |> list.map(bool.to_int)
  |> int.sum
  |> io.debug
}

fn to_int(s: String) {
  result.unwrap(int.parse(s), 0)
}

fn is_safe(l: List(Int)) {
  list.window_by_2(l)
  |> fn(windows) {
    are_ascending_safely(windows) || are_descending_safely(windows)
  }
}

fn are_ascending_safely(windows: List(#(Int, Int))) {
  list.all(windows, fn(w) { w.0 < w.1 && has_safe_magnitude(w) })
}

fn are_descending_safely(windows: List(#(Int, Int))) {
  list.all(windows, fn(w) { w.0 > w.1 && has_safe_magnitude(w) })
}

fn has_safe_magnitude(window: #(Int, Int)) {
  int.subtract(window.0, window.1)
  |> int.absolute_value
  < 4
}
