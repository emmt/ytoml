if (is_func(plug_in)) plug_in, "ytoml";

extern toml_parse;
extern toml_parse_file;
/* DOCUMENT tbl = toml_parse(buffer);
         or tbl = toml_parse_file(filename);

     Extract a TOML table from a string buffer or from a file.

     Entries in a table can be accessed by, nothing to yield the number of
     entries, by an integer index `idx` or by a string `key`:

         len = tbl();     // number of entries
         val = tbl(key);  // entry at string key
         val = tbl(idx);  // entry at integer index
         val = tbl(0);    // last entry,
         val = tbl(-1);   // before last entry, and so on

     where the value `val` can be:

     • a boolean represented by a Yorick's `int`: `0n` for false, `1n` for true;
     • an integer represented by a Yorick's `long`;
     • a floating-point represented by a Yorick's `double`;
     • a string represented by a Yorick's `string`;
     • a TOML table;
     • a TOML array;
     • a TOML timestamp.

     A TOML array is similar to a TOML table except that it can only be indexed
     by integers.

     A TOML timestamp, say `ts` has the follwing members:
     • `ts.year` is the year (a `long`);
     • `ts.month` is month (a `long`, 1 for January);
     • `ts.day` is the day of the month (a `long`);
     • `ts.hour` is the hour  (a `long`);
     • `ts.minute` is the number of minutes (a `long`);
     • `ts.second` is the number of seconds with millisecond precision (a `double`);
     • `ts.tz` the time-zone (a `string`);
     • `ts.kind` the kind of timestamp (a `char`): 'd' for offset datetime, 'l'
	   for local datetime, 'D' for local date, or 't' for locat time.

     The number of entries in a TOML table or array, say `obj`, is given by
     `obj.len` and Yorick's indexing rules hold, that is `obj(0)` yields the
     last entry, `obj(-1)` yields the before last entry and so on.

     Other members are:

     • `obj.len` and `obj()` yield the number of entries in `obj`;
     • `obj.root` yields the root TOML table to which `obj` belongs to;
     • `obj.is_root` yields whether `obj` is the root TOML table;

   SEE ALSO: `toml_key`, `toml_length`, and `toml_type`.
 */

local TOML_OTHER, TOML_TABLE, TOML_ARRAY, TOML_TIMESTAMP;
extern toml_type;
/* DOCUMENT id = toml_type(obj);

     The call `toml_type(obj)` yields:
     • `TOML_TABLE` (1) if `obj` is a TOML table,
     • `TOML_ARRAY` (2) if `obj` is a TOML array,
     • `TOML_TIMESTAMP` (3) if `obj` is a TOML timestamp,
     • `TOML_OTHER` (0) otherwise.

   SEE ALSO: `toml_key`, `toml_length`, and `toml_parse`.
 */
TOML_OTHER     = 0n;
TOML_TABLE     = 1n;
TOML_ARRAY     = 2n;
TOML_TIMESTAMP = 3n;

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
