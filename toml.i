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

   SEE ALSO: `toml_type`.
 */

extern toml_type;
/* DOCUMENT id = toml_type(obj);

     Yield 1 if `obj` is a TOML table, 2 if `obj` is a TOML table, and 0 otherwise.

   SEE ALSO: `toml_parse` and `toml_parse_file`.
 */
