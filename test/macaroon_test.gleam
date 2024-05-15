import gleam/io
import gleam/list
import gleeunit
import gleeunit/should
import macaroon

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn storage_test() {
  let jar =
    macaroon.init()
    |> macaroon.put([#("One", "1"), #("secure", "true")])
    |> macaroon.put([#("Two", "2")])
    |> macaroon.put([#("Three", "3")])
    |> macaroon.put([#("Four", "4")])

  jar
  |> macaroon.peek
  |> list.each(fn(cookie) { io.debug(cookie) })
}
