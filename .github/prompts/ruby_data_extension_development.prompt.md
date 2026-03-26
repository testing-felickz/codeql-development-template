---
mode: agent
---

# Ruby Data Extension

For general CodeQL data extension model development guidance, see [Common Data Extension Development](./data_extensions_development.prompt.md).
For general CodeQL query development guidance, see [Common Query Development](./query_development.prompt.md).

## Ruby-Specific Documentation

### Ruby Documentation

- [Customizing Library Models for Ruby](https://codeql.github.com/docs/codeql-language-guides/customizing-library-models-for-ruby/)
  - Can also be found at [Customizing Library Models for Ruby Docs](https://github.com/github/codeql/blob/main/docs/codeql/codeql-language-guides/customizing-library-models-for-ruby.rst)

- [Using API graphs in Ruby](https://codeql.github.com/docs/codeql-language-guides/using-api-graphs-in-ruby/) - access paths in extensions are powered by API graphs

### Model Format

Ruby uses an **API Graph-based** model format with short tuples — similar to Python and JavaScript.

The pack name is `codeql/ruby-all`.

#### Extensible predicates

| Predicate | Columns | Purpose |
|---|---|---|
| `sourceModel` | `(type, path, kind)` | Model sources of tainted data |
| `sinkModel` | `(type, path, kind)` | Model sinks where tainted data is used vulnerably |
| `summaryModel` | `(type, path, input, output, kind)` | Model flow through method calls |
| `typeModel` | `(type1, type2, path)` | Define type relationships |

#### Type column

The `type` column identifies a starting point for access path evaluation:
- A class name like `"TTY::Command"` matches instances of that class
- Appending `!` (e.g., `"Sinatra::Base!"`) matches references to the **class itself** rather than instances
- `typeModel` rows can define aliases so that subtypes inherit all models from a parent type

### Access Paths

Access paths are `.`-separated, evaluated left to right:

| Component | Description |
|---|---|
| `Method[name]` | Calls to the named method |
| `Argument[n]` | Argument at index n |
| `Argument[name:]` | Keyword argument with the given name |
| `Argument[self]` | The receiver of a method call |
| `Argument[block]` | The block argument |
| `Argument[any]` | Any argument (except self/block) |
| `Argument[any-named]` | Any keyword argument |
| `Argument[hash-splat]` | All keyword arguments (`**kwargs`) |
| `Parameter[n]` | Parameter at index n |
| `Parameter[name:]` | Keyword parameter with the given name |
| `Parameter[self]` | The self parameter |
| `Parameter[block]` | The block parameter |
| `Parameter[any]` | Any parameter (except self/block) |
| `Parameter[any-named]` | Any keyword parameter |
| `Parameter[hash-splat]` | Hash splat parameter |
| `ReturnValue` | Return value of a call |
| `Element[any]` | Any element of an array or hash |
| `Element[n]` | Array element at the given index |
| `Element[key]` | Hash element at the given key |
| `Field[@name]` | Instance variable with the given name |
| `Fuzzy` | All values derived from the current value (approximate) |

**Syntax notes:**
- Multiple operands: `Method[foo,bar]` matches calls to either `foo` or `bar`
- Numeric ranges: `Argument[1..]` matches all arguments from index 1 onward

### Sink Kinds

`code-injection`, `command-injection`, `path-injection`, `sql-injection`, `url-redirection`, `log-injection`

### Sample Model

Given a snippet using the `tty-command` gem:

```ruby
tty = TTY::Command.new
tty.run(cmd) # sink: command injection
```

`tty_command.model.yml`

```yaml
extensions:
  - addsTo:
      pack: codeql/ruby-all
      extensible: sourceModel
    data: []

  - addsTo:
      pack: codeql/ruby-all
      extensible: sinkModel
    data:
      - ["TTY::Command", "Method[run].Argument[0]", "command-injection"]

  - addsTo:
      pack: codeql/ruby-all
      extensible: summaryModel
    data: []

  - addsTo:
      pack: codeql/ruby-all
      extensible: typeModel
    data: []
```

### Example: Flow Through a Method

Model flow through `URI.decode_uri_component`:

```yaml
extensions:
  - addsTo:
      pack: codeql/ruby-all
      extensible: summaryModel
    data:
      - ["URI!", "Method[decode_uri_component]", "Argument[0]", "ReturnValue", "taint"]
```

Note: `URI!` with the `!` suffix matches the class itself (not instances), since `decode_uri_component` is a class method.

### Example: Source from Block Parameters

Model `x` in a Sinatra route block as a remote source:

```yaml
extensions:
  - addsTo:
      pack: codeql/ruby-all
      extensible: sourceModel
    data:
      - ["Sinatra::Base!", "Method[get].Argument[block].Parameter[0]", "remote"]
```

### Example: typeModel for Subclass Inheritance

When `Mysql2::EM::Client` is a subclass of `Mysql2::Client`, add a type model so all parent models apply:

```yaml
extensions:
  - addsTo:
      pack: codeql/ruby-all
      extensible: typeModel
    data:
      - ["Mysql2::Client", "Mysql2::EM::Client", ""]
```

### Additional References
- **[Ruby Reference](./ruby_query_development.prompt.md)** - Ruby query development
