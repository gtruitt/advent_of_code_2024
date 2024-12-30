import gleam/dict
import gleam/int
import gleam/io
import gleam/list
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
  |> list_antinodes
  |> list.map(fn(a) {
    case a {
      Ok(_) -> 1
      Error(_) -> 0
    }
  })
  |> int.sum
  |> io.debug
  // expecting 14
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

fn list_antinodes(field: Field) {
  list.map(dict.values(field.frequencies), fn(points) {
    list.map(points, fn(outer) {
      list.map(points, fn(inner) {
        case outer == inner {
          True -> Error(Nil)
          False -> {
            let distance = Point(outer.x - inner.x, outer.y - inner.y)
            let antinode = Point(outer.x + distance.x, outer.y + distance.y)
            case dict.get(field.map, antinode) {
              Ok(_) -> Ok(antinode)
              Error(_) -> Error(Nil)
            }
          }
        }
      })
    })
  })
  |> list.flatten
  |> list.flatten
  |> list.unique
}
