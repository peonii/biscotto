# macaroon

[![Package Version](https://img.shields.io/hexpm/v/macaroon)](https://hex.pm/packages/macaroon)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/macaroon/)

```sh
gleam add macaroon
```

```gleam
import macaroon
import gleam/http/request

pub fn main() {
  let jar = macaroon.init()

  let jar = jar
  |> macaroon.put(List(#("key", "value")))

  let assert Ok(req) = request.to("https://example.com")

  let req = req
  |> macaroon.add(jar)
}
```

Further documentation can be found at <https://hexdocs.pm/macaroon>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
