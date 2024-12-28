import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/otp/task
import gleam/result
import gleam/string
import simplifile as file

pub fn solve() {
  file.read("example_data/day_06")
  |> result.unwrap("")
  |> string.trim
  |> string.split("\n")
  |> list.map(string.split(_, ""))
  |> read_lab
  |> fn(lab) {
    let origin = lab.guard.point
    let patrolled = patrol(lab)
    list.fold(dict.keys(patrolled.map), [], fn(acc, point) {
      case point == origin, dict.get(patrolled.map, point) {
        False, Ok("X") -> {
          let lab_n = Lab(..lab, map: dict.insert(lab.map, point, "#"))
          [task.async(fn() { patrol(lab_n) }), ..acc]
        }
        _, _ -> acc
      }
    })
  }
  |> list.map(task.await_forever)
  |> list.map(fn(lab) { bool.to_int(lab.has_loop) })
  |> int.sum
  |> io.debug
  // expecting 6
}

pub type Point {
  Point(x: Int, y: Int)
}

pub type Guard {
  Guard(point: Point, stance: String)
}

pub type Terrain {
  Terrain(point: Point, kind: String)
}

pub type Lab {
  Lab(
    map: dict.Dict(Point, String),
    guard: Guard,
    turns: List(Point),
    has_loop: Bool,
  )
}

fn read_lab(map_chars: List(List(String))) -> Lab {
  list.index_fold(
    map_chars,
    Lab(dict.new(), Guard(Point(0, 0), "+"), [], False),
    fn(lab, dim_x, index_y) {
      list.index_fold(dim_x, lab, fn(lab, char, index_x) {
        Lab(
          ..lab,
          map: dict.insert(lab.map, Point(index_x, index_y), char),
          guard: case char {
            "^" -> Guard(Point(index_x, index_y), char)
            _ -> lab.guard
          },
        )
      })
    },
  )
}

fn patrol(lab: Lab) -> Lab {
  case next_step(lab) {
    Terrain(p, "|") ->
      Lab(
        ..lab,
        map: dict.insert(lab.map, lab.guard.point, "X"),
        guard: Guard(..lab.guard, point: p),
      )
    Terrain(p, ".") | Terrain(p, "X") ->
      patrol(
        Lab(
          ..lab,
          map: dict.insert(lab.map, lab.guard.point, "X"),
          guard: Guard(..lab.guard, point: p),
        ),
      )
    Terrain(_, "#") -> {
      let new_turns = [lab.guard.point, ..lab.turns]
      case has_loop(new_turns, 4) {
        True -> Lab(..lab, has_loop: True)
        False ->
          patrol(
            Lab(
              ..lab,
              map: lab.map,
              guard: Guard(..lab.guard, stance: next_stance(lab.guard.stance)),
              turns: new_turns,
            ),
          )
      }
    }
    Terrain(_, _) -> panic
  }
}

fn next_step(lab: Lab) -> Terrain {
  let offset = case lab.guard.stance {
    "^" -> Point(0, -1)
    ">" -> Point(1, 0)
    "v" -> Point(0, 1)
    "<" -> Point(-1, 0)
    _ -> panic
  }
  let next_point =
    Point(lab.guard.point.x + offset.x, lab.guard.point.y + offset.y)
  case dict.get(lab.map, next_point) {
    Ok(kind) -> Terrain(next_point, kind)
    Error(_) -> Terrain(next_point, "|")
  }
}

fn next_stance(stance: String) -> String {
  case stance {
    "^" -> ">"
    ">" -> "v"
    "v" -> "<"
    "<" -> "^"
    _ -> panic
  }
}

fn has_loop(turns: List(Point), min_length: Int) -> Bool {
  case list.length(turns) >= min_length * 2 {
    True ->
      list.take(turns, min_length)
      == list.drop(turns, min_length) |> list.take(min_length)
      || has_loop(turns, min_length + 1)
    False -> False
  }
}
