import gleam/dict
import gleam/int
import gleam/io
import gleam/list
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
  |> patrol
  |> fn(lab) {
    dict.values(lab.map)
    |> list.map(fn(terrain_kind) {
      case terrain_kind {
        "X" -> 1
        _ -> 0
      }
    })
  }
  |> int.sum
  |> io.debug
  // expecting 41
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
  Lab(map: dict.Dict(Point, String), guard: Guard)
}

fn read_lab(map_chars: List(List(String))) -> Lab {
  list.index_fold(
    map_chars,
    Lab(dict.new(), Guard(Point(0, 0), "+")),
    fn(lab, dim_x, index_y) {
      list.index_fold(dim_x, lab, fn(lab, char, index_x) {
        Lab(dict.insert(lab.map, Point(index_x, index_y), char), case char {
          "^" -> Guard(Point(index_x, index_y), char)
          _ -> lab.guard
        })
      })
    },
  )
}

fn patrol(lab: Lab) -> Lab {
  case next_step(lab) {
    Terrain(p, ":") ->
      Lab(
        dict.insert(lab.map, lab.guard.point, "X"),
        Guard(..lab.guard, point: p),
      )
    Terrain(p, ".") | Terrain(p, "X") ->
      patrol(Lab(
        dict.insert(lab.map, lab.guard.point, "X"),
        Guard(..lab.guard, point: p),
      ))
    Terrain(_, "#") ->
      patrol(Lab(
        lab.map,
        Guard(..lab.guard, stance: next_stance(lab.guard.stance)),
      ))
    Terrain(_, kind) -> {
      io.debug(kind)
      panic
    }
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
    Error(_) -> Terrain(next_point, ":")
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
