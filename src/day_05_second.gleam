import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order
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

    let rule_sorter = build_sorter(rules)

    string.split(updates_text, "\n")
    |> list.map(string.split(_, ","))
    |> list.map(list.map(_, string_to_int))
    |> list.map(fn(update) {
      case is_good(rules, update) {
        True -> []
        False -> list.sort(update, rule_sorter)
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
  // expecting 123
}

fn build_sorter(rules: List(#(Int, Int))) {
  let sort_rules =
    list.fold(rules, dict.new(), fn(sort_rules, rule) {
      let sort_rule = fn(a, b) {
        case rule == #(a, b), rule == #(b, a) {
          True, _ -> order.Lt
          _, True -> order.Gt
          _, _ -> panic
        }
      }
      dict.insert(sort_rules, rule, sort_rule)
    })
  fn(a, b) {
    case dict.get(sort_rules, #(a, b)), dict.get(sort_rules, #(b, a)) {
      Ok(rule), _ | _, Ok(rule) -> rule(a, b)
      _, _ -> panic
    }
  }
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
