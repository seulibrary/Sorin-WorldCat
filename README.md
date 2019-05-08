# SorinWorldcat

Sorin Worldcat is a [Sorin](https://github.com/seulibrary/Sorin) extension that provides the [WorldCat Search API](https://www.oclc.org/developer/develop/web-services/worldcat-search-api.en.html) as a catalog search endpoint.

Sorin catalog search extensions are responsible for two services:

* Receiving search requests from Sorin's `Search` module, rebuilding them as appropriate for the given catalog's API, and issuing them to the catalog;
* Receiving the catalog's results, parsing them into Elixir maps based on Sorin's `Resource` schema, and returning them to the `Search` module, which returns them to the client.

Sorin Worldcat encodes all of this functionality in `lib/sorin_worldcat.ex`.

## Installation

1. Add the following to Sorin's root-level `mix.exs`:

```elixir
def deps do
  [
    {:sorin_worldcat, git: "https://github.com/seulibrary/Sorin-WorldCat.git"},
  ]
end
```

2. From the root of the application:

```sh
$ mix deps.get && mix deps.compile
```

3. Edit the `search` stanza in `sorin.exs` to point it at `SorinWorldcat`:

```elixir
config :search,
  search_target: SorinWorldcat
```

4. Add the following stanza to `sorin.exs`, updating the `wskey` and `result_format` keys as necessary:

```elixir
config :sorin_worldcat,
  wskey: "[Your WSKey]",
  result_format: "&recordSchema=info%3Asrw%2Fschema%2F1%2Fdc"
```

## Notes:

* If you have other catalog extensions installed, it is not necessary to remove their configuration stanzas from `sorin.exs`.
* If you are using the _Sorin Search Filter_ extension, it will be necessary to update it to accommodate [WorldCat's API](https://www.oclc.org/developer/develop/web-services/worldcat-search-api/bibliographic-resource.en.html). See the README file for _Sorin Search Filter_ for instructions.
* If you do not already have one, you will need to get a [WorldCat WSKey](https://www.oclc.org/developer/develop/authentication/how-to-request-a-wskey.en.html) to use this extension.
