# Style Guide for this code

- Structs types and namespaces should be in `ProudCamelCase` (like Elixir Modules)
- scalar types should be in `snake_case_t` with a `_t` postfix sigil (like C)
- variables should be in `snake_case` with no sigils.
- constants should be `YELLING`
- do aliasing imports to convert standard zig styles into local styles at top of file.
- structure filesystem like Elixir
- prefer calling functions using explicit calls instead of using self sugar
  - this makes it explicit if a function call is mutating or not. 
- follow the zig style otherwise
