# biscotto

[![Package Version](https://img.shields.io/hexpm/v/biscotto)](https://hex.pm/packages/biscotto)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/biscotto/)

```sh
gleam add biscotto
```

```gleam
import biscotto
import gleam/http/request

pub fn main() {
  let jar = biscotto.init()

  let jar = jar
  |> biscotto.put(List(#("key", "value")))

  let assert Ok(req) = request.to("https://example.com")

  let req = req
  |> biscotto.add(jar)
}
```

Further documentation can be found at <https://hexdocs.pm/biscotto>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
