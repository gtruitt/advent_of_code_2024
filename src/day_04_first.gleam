import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile as file

pub fn solve() {
  file.read("example_data/day_04")
  |> result.unwrap("")
  |> string.trim
  |> string.split("\n")
  |> list.map(string.split(_, ""))
  |> list.index_fold(dict.new(), fn(acc_x, item_x, idx_x) {
    list.index_fold(item_x, acc_x, fn(acc_y, item_y, idx_y) {
      dict.insert(acc_y, #(idx_x, idx_y), item_y)
    })
  })
  |> fn(field: Dict(#(Int, Int), String)) {
    dict.map_values(field, fn(point: #(Int, Int), letter: String) {
      case letter {
        "X" -> is_xmas(field, letter, point)
        _ -> [False]
      }
    })
  }
  |> dict.values()
  |> list.flatten
  |> list.map(bool.to_int)
  |> int.sum
  |> io.debug
  // expecting 18
}

fn is_xmas(
  field: dict.Dict(#(Int, Int), String),
  letter: String,
  point: #(Int, Int),
) {
  list.map(
    [
      #(-1, 0),
      #(-1, 1),
      #(0, 1),
      #(1, 1),
      #(1, 0),
      #(1, -1),
      #(0, -1),
      #(-1, -1),
    ],
    fn(op: #(Int, Int)) { is_xmas_loop(field, letter, point, op) },
  )
}

fn is_xmas_loop(
  field: dict.Dict(#(Int, Int), String),
  letter: String,
  point: #(Int, Int),
  op: #(Int, Int),
) {
  let next_point = #(point.0 + op.0, point.1 + op.1)
  let next_letter = dict.get(field, next_point)
  case letter, next_letter {
    "X", Ok("M" as n) | "M", Ok("A" as n) ->
      is_xmas_loop(field, n, next_point, op)
    "A", Ok("S") -> True
    _, _ -> False
  }
}
