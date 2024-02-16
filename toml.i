if (is_func(plug_in)) plug_in, "ytoml";

extern toml_parse;
extern toml_parse_file;
/* DOCUMENT tbl = toml_parse(buffer);
         or tbl = toml_parse_file(filename);

     Extract a TOML table from a string buffer or from a file.

     Entries in a table can be accessed by an integer index `idx` or by a
     string `key`:

         val = tbl(key)
         val = tbl(idx)

     where the value `val` can be:

     - a boolean represented by a Yorick's `int`: `0n` for false, `1n` for true;
     - an integer represented by a Yorick's `long`;
     - a floating-point represented by a Yorick's `double`;
     - a string represented by a Yorick's `string`;
     - a timestamp;
     - a TOML table;
     - a TOML array.

     A TOML array is similar to a TOML table except that it can only be indexed
     by integers.

     The number of entries in a TOML table or array, say `obj`, is given by
     `obj.len` and Yorick's indexing rules hold, that is `obj(0)` yields the
     last entry, `obj(-1)` yields the before last entry and so on.

     Other members are:

     - `obj.len` yields the number of entries in `obj`;
     - `obj.root` yields the root TOML table to which `obj` belongs to;
     - `obj.is_root` yields whether `obj` is the root TOML table;

   SEE ALSO: `toml_key`, `toml_length`, and ``toml_type`.
 */

extern toml_type;
/* DOCUMENT id = toml_type(obj);

     Yield 1 if `obj` is a TOML table, 2 if `obj` is a TOML table, and 0 otherwise.

   SEE ALSO: `toml_key`, `toml_length`, and `toml_parse`.
 */

extern toml_length;
/* DOCUMENT n = toml_length(obj);

     The call `toml_length(obj)` yields the number of entries in object `obj`
     if it is a TOML table or a TOML array, and yields `-1` otherwise. This is
     like the syntax `obj.len` except that `obj` may be neither a TOML table
     nor a TOML array

  SEE ALSO: `toml_key`, `toml_parse`, and `toml_type`.
 */

extern toml_key;
extern toml_keys;
/* DOCUMENT key = toml_key(tbl, idx);
         or keys = toml_keys(tbl);

     The call `toml_key(tbl, idx)` yields the string key for the `idx`-th entry
     of TOML table `tbl`. Yorick indexing rules are applied: `toml_key(tbl, 0)`
     yields the last key, `toml_key(tbl, -1)` yields the before last key and so
     on. If index is out of range, `(nil)` is returned, thus:

         n = 0;
         while (toml_key(tbl, n+1)) ++n;

     is valid code to determine the number of keys (although `tbl.len` or
     `toml_length(tbl)` are preferable).

     The call `toml_key(tbl)` yields all the keys of the TOML table `tbl` as a
     vector of strings.

   SEE ALSO: `toml_length`, `toml_parse`, and `toml_type`.
 */
