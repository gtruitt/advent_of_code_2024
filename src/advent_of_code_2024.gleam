import birl
import birl/duration
import day_04_second.{solve}
import gleam/io

pub fn main() {
  let start = birl.now()
  solve()
  let diff = birl.difference(birl.now(), start)
  io.debug(duration.blur(diff))
}
