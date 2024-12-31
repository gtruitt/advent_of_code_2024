import gleam/dict
import gleam/function.{identity}
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import simplifile as file

pub fn solve() {
  file.read("example_data/day_08")
  |> result.unwrap("")
  |> string.trim
  |> string.split("\n")
  |> list.map(string.split(_, ""))
  |> read_field
  |> fn(field) {
    let antinodes = list_antinodes(field)
    display(field.map, antinodes)
    antinodes
  }
  |> list.length
  |> io.debug
  // expecting 34
}

pub type Point {
  Point(x: Int, y: Int)
}

pub type Field {
  Field(
    map: dict.Dict(Point, String),
    frequencies: dict.Dict(String, List(Point)),
  )
}

fn read_field(map_chars: List(List(String))) -> Field {
  list.index_fold(
    map_chars,
    Field(dict.new(), dict.new()),
    fn(field, dim_x, index_y) {
      list.index_fold(dim_x, field, fn(field, char, index_x) {
        Field(
          map: dict.insert(field.map, Point(index_x, index_y), char),
          frequencies: case char {
            "." -> field.frequencies
            f ->
              case dict.get(field.frequencies, f) {
                Ok(antennas) ->
                  dict.insert(field.frequencies, f, [
                    Point(index_x, index_y),
                    ..antennas
                  ])
                Error(_) ->
                  dict.insert(field.frequencies, f, [Point(index_x, index_y)])
              }
          },
        )
      })
    },
  )
}

fn list_antinodes(field: Field) -> List(Point) {
  list.flat_map(dict.values(field.frequencies), fn(points) {
    list.flat_map(points, fn(outer) {
      list.flat_map(points, fn(inner) {
        case outer == inner {
          True -> [Error(Nil)]
          False ->
            resonance_walk(outer, inner, field.map, [Ok(outer), Ok(inner)])
        }
      })
    })
  })
  |> list.filter_map(identity)
  |> list.unique
}

fn resonance_walk(
  a: Point,
  b: Point,
  map: dict.Dict(Point, String),
  into: List(Result(Point, Nil)),
) {
  let distance = Point(a.x - b.x, a.y - b.y)
  let antinode = Point(a.x + distance.x, a.y + distance.y)
  case dict.get(map, antinode) {
    Ok(_) -> resonance_walk(antinode, a, map, [Ok(antinode), ..into])
    Error(_) -> into
  }
}

fn display(map: dict.Dict(Point, String), antinodes: List(Point)) {
  let full_map =
    list.fold(antinodes, map, fn(acc, a) { dict.insert(acc, a, "#") })

  let sorted_points =
    list.sort(dict.keys(full_map), fn(a, b) {
      case a.y > b.y || { a.y == b.y && a.x > b.x } {
        True -> order.Gt
        False -> order.Lt
      }
    })

  let dim_y = case list.last(sorted_points) {
    Ok(p) -> p.y + 1
    Error(_) -> panic
  }

  let rows = list.sized_chunk(sorted_points, dim_y)

  list.map(rows, fn(col) {
    list.map(col, fn(it) {
      case dict.get(full_map, it) {
        Ok(c) -> c
        Error(_) -> panic
      }
    })
  })
  |> list.map(string.join(_, " "))
  |> list.map(io.debug)
  Nil
}
