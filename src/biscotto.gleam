////
//// Biscotto
////
//// Biscotto is a Gleam library to store and manage cookies with a jar.
////

import gleam/dict.{type Dict}
import gleam/http/cookie
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/list

/// A cookie.
pub type Cookie {
  Cookie(
    name: String,
    value: String,
    domain: String,
    path: String,
    expires: String,
    secure: Bool,
  )
}

/// A jar to store cookies.
pub type CookieJar {
  CookieJar(cookies: Dict(String, Cookie))
}

/// Create a new cookie jar.
///
/// ```gleam
/// let jar = biscotto.init()
/// ```
pub fn init() -> CookieJar {
  CookieJar(cookies: dict.new())
}

/// Get all cookies from a jar.
///
/// ```gleam
/// let jar = biscotto.init()
///
/// // Do something with the jar
///
/// let first_cookie = jar
/// |> biscotto.peek
/// |> list.first
/// ```
pub fn peek(jar: CookieJar) -> List(Cookie) {
  jar.cookies
  |> dict.values
}

/// Get a specific cookie from the jar, by its name.
///
/// ```gleam
/// let jar = biscotto.init()
///
/// // Do something with the jar
///
/// let cookie = jar |> biscotto.get("my_cookie")
/// ```
pub fn get(jar: CookieJar, key: String) -> Result(Cookie, Nil) {
  jar.cookies
  |> dict.get(key)
}

fn cookie_from_list(cookie: List(#(String, String))) -> Result(Cookie, Nil) {
  let kv = list.first(cookie)
  case kv {
    Ok(kv) -> {
      let #(key, value) = kv

      let expires = case
        list.find(cookie, fn(el) {
          let #(name, _) = el
          name == "expires"
        })
      {
        Ok(expires) -> expires.1
        Error(_) -> ""
      }

      let domain = case
        list.find(cookie, fn(el) {
          let #(name, _) = el
          name == "domain"
        })
      {
        Ok(domain) -> domain.1
        Error(_) -> ""
      }

      let path = case
        list.find(cookie, fn(el) {
          let #(name, _) = el
          name == "path"
        })
      {
        Ok(path) -> path.1
        Error(_) -> ""
      }

      let secure = case
        list.find(cookie, fn(el) {
          let #(name, _) = el
          name == "secure"
        })
      {
        Ok(secure) -> secure.1 == "true"
        Error(_) -> False
      }

      Ok(Cookie(
        name: key,
        value: value,
        domain: domain,
        path: path,
        expires: expires,
        secure: secure,
      ))
    }
    Error(_) -> Error(Nil)
  }
}

/// Add a cookie to the jar.
///
/// ```gleam
/// let jar = biscotto.init()
///
/// let cookie = [
///  #("name", "value"),
///  #("domain", "example.com"),
///  #("path", "/")
/// ]
///
/// let jar = biscotto.put(jar, cookie)
pub fn put(jar: CookieJar, cookie: List(#(String, String))) -> CookieJar {
  case cookie_from_list(cookie) {
    Ok(cookie) -> {
      CookieJar(
        cookies: jar.cookies
        |> dict.insert(cookie.name, cookie),
      )
    }
    Error(_) -> {
      jar
    }
  }
}

/// Remove a cookie from the jar.
///
/// ```gleam
/// let jar = biscotto.init()
///
/// let jar = biscotto.remove(jar, "my_cookie")
///
/// let assert Error(_) = jar |> biscotto.get("my_cookie")
/// ```
pub fn remove(jar: CookieJar, key: String) -> CookieJar {
  CookieJar(
    cookies: jar.cookies
    |> dict.delete(key),
  )
}

/// Parse cookies from a response and add them to a jar.
///
/// ```gleam
/// let jar = biscotto.init()
///
/// // Perform a request
/// use response <- result.try(httpc.send(req))
///
/// let jar = jar
/// |> biscotto.from_response(response)
/// ```
pub fn from_response(jar: CookieJar, resp: Response(a)) -> CookieJar {
  let response.Response(headers: headers, ..) = resp
  headers
  |> list.filter_map(fn(header) {
    let #(name, value) = header
    case name {
      "set-cookie" -> Ok(cookie.parse(value))
      _ -> Error(Nil)
    }
  })
  |> list.fold(jar, fn(jar, cookie) {
    case cookie_from_list(cookie) {
      Ok(cookie) -> {
        CookieJar(
          cookies: jar.cookies
          |> dict.insert(cookie.name, cookie),
        )
      }
      Error(_) -> {
        jar
      }
    }
  })
}

/// Add cookies to a request.
///
/// ```gleam
/// let jar = biscotto.init()
///
/// let assert Ok(req) = request.to("https://example.com")
///
/// let req = biscotto.with_cookies(req, jar)
/// ```
pub fn with_cookies(req: Request(a), jar: CookieJar) -> Request(a) {
  jar.cookies
  |> dict.fold(req, fn(req, key, cookie) {
    req
    |> request.set_cookie(key, cookie.value)
  })
}
