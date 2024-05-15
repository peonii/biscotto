import biscotto
import gleam/io
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn storage_test() {
  let jar =
    biscotto.init()
    |> biscotto.put([#("One", "1"), #("secure", "true")])
    |> biscotto.put([#("Two", "2")])
    |> biscotto.put([#("Three", "3")])
    |> biscotto.put([#("Four", "4")])

  jar
  |> biscotto.peek
  |> list.each(fn(cookie) { io.debug(cookie) })
}
