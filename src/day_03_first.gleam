import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, Some}
import gleam/regexp
import gleam/result
import gleam/string
import simplifile as file

pub fn solve() {
  file.read("example_data/day_03_first")
  |> result.unwrap("")
  |> string.trim
  |> get_muls
  |> list.map(fn(p) { p.0 * p.1 })
  |> int.sum
  |> io.debug
  // expecting 161
}

fn get_muls(s: String) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)")
  regexp.scan(re, s)
  |> list.map(fn(match) {
    let assert Ok(first_submatch) = list.first(match.submatches)
    let assert Ok(last_submatch) = list.last(match.submatches)
    #(get_int(first_submatch), get_int(last_submatch))
  })
}

fn get_int(os: Option(String)) {
  let assert Some(s) = os
  let assert Ok(i) = int.parse(s)
  i
}
