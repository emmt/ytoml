- `tbl.keys` yields the list of keys for a TOML table `tbl`.
- Make timestamps Yorick objects.
- Use `yget_use`, `ypush_use`, and `ydrop_use` to manage the root object.
- Check for memory leaks and memory allocation errors in TOML
  parser.
- Switch to [tomlc99](https://github.com/cktan/tomlc99) for parsing TOML.
- Yorick function to write a TOML file.
- Yorick function to convert a TOML table to a Yeti hash table.
- To represent TOML arrays, create a new Yorick vector-like type of object to
  store any kind of objects (fast scalars and `DataBlock`). Perhaps similar to
  Yeti's tuples but writable. Better, make these objects resizable as Julia's
  vectors.
