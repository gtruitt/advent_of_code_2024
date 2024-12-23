import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile as file

pub fn solve() {
  file.read("example_data/day_05")
  |> result.unwrap("")
  |> string.trim
  |> string.split("\n\n")
  |> fn(halves) {
    let #(rules_text, updates_text) = case halves {
      [a, b] -> #(a, b)
      _ -> panic
    }

    let rules =
      string.split(rules_text, "\n")
      |> list.map(string.split(_, "|"))
      |> list.map(fn(rule) {
        case rule {
          [a, b] -> #(string_to_int(a), string_to_int(b))
          _ -> panic
        }
      })

    string.split(updates_text, "\n")
    |> list.map(string.split(_, ","))
    |> list.map(list.map(_, string_to_int))
    |> list.map(fn(update) {
      case is_good(rules, update) {
        True -> update
        False -> []
      }
    })
  }
  |> list.map(fn(update) {
    case update {
      [] -> 0
      _ as items -> middle_item(items)
    }
  })
  |> int.sum
  |> io.debug
  // expecting 143
}

fn middle_item(items: List(Int)) {
  let middle =
    items
    |> list.drop(list.length(items) / 2)
    |> list.first()

  case middle {
    Ok(mid) -> mid
    Error(_) -> panic
  }
}

fn is_good(rules: List(#(Int, Int)), update: List(Int)) {
  let up =
    list.index_map(update, fn(it, idx) { #(it, idx) })
    |> dict.from_list

  list.all(rules, fn(rule) {
    case dict.get(up, rule.0), dict.get(up, rule.1) {
      Ok(left), Ok(right) -> left < right
      _, _ -> True
    }
  })
}

fn string_to_int(s: String) {
  case int.parse(s) {
    Ok(i) -> i
    Error(_) -> panic
  }
}
