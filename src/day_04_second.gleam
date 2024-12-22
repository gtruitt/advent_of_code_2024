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
        "A" -> is_x_mas(field, point)
        _ -> False
      }
    })
  }
  |> dict.values()
  |> list.map(bool.to_int)
  |> int.sum
  |> io.debug
  // expecting 9
}

fn is_x_mas(field: dict.Dict(#(Int, Int), String), point: #(Int, Int)) {
  let get_letter = relative_letter(field, point, _)
  let top_bottom_letters = #(#(get_letter(#(-1, -1)), get_letter(#(1, -1))), #(
    get_letter(#(-1, 1)),
    get_letter(#(1, 1)),
  ))
  let left_right_letters = #(#(get_letter(#(-1, -1)), get_letter(#(-1, 1))), #(
    get_letter(#(1, -1)),
    get_letter(#(1, 1)),
  ))

  let ms = #(#("M", "M"), #("S", "S"))
  let sm = #(#("S", "S"), #("M", "M"))

  top_bottom_letters == ms
  || top_bottom_letters == sm
  || left_right_letters == ms
  || left_right_letters == sm
}

fn relative_letter(
  field: dict.Dict(#(Int, Int), String),
  point: #(Int, Int),
  offset: #(Int, Int),
) {
  let relative_point = #(point.0 + offset.0, point.1 + offset.1)
  case dict.get(field, relative_point) {
    Ok(letter) -> letter
    Error(_) -> ""
  }
}
