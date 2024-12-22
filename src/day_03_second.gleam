import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, Some}
import gleam/regexp
import gleam/result
import gleam/string
import simplifile as file

pub fn solve() {
  file.read("example_data/day_03_second")
  |> result.unwrap("")
  |> string.trim
  |> get_total
  |> io.debug
  // expecting 48
}

fn get_total(s: String) {
  let assert Ok(re) =
    regexp.from_string(
      "mul\\((\\d{1,3}),(\\d{1,3})\\)|(do\\(\\))|(don't\\(\\))",
    )
  regexp.scan(re, s)
  |> process_muls("do()", 0)
}

fn process_muls(l: List(regexp.Match), last_cmd: String, total: Int) {
  case l {
    [] -> total
    [head, ..tail] ->
      case head.content {
        "do()" | "don't()" -> process_muls(tail, head.content, total)
        _ -> {
          case last_cmd {
            "do()" -> {
              let assert Ok(sub_a) = list.first(head.submatches)
              let assert Ok(sub_b) = list.last(head.submatches)
              let new_total = total + { get_int(sub_a) * get_int(sub_b) }
              process_muls(tail, last_cmd, new_total)
            }
            "don't()" -> process_muls(tail, last_cmd, total)
            _ -> panic
          }
        }
      }
  }
}

fn get_int(opt: Option(String)) {
  let assert Some(s) = opt
  let assert Ok(i) = int.parse(s)
  i
}
