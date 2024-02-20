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

func toml_load(filename, broadcast=)
/* DOCUMENT data = toml_load(filename, broadcast=false);

     `toml_load(filename)` parse the contents of the TOML file `filename` and
     returns it as a hash table. Keyword `broadcast` specifies whether Yorick's
     broadcasting rules apply when collecting TOML arrays.

   SEE ALSO: `toml_parse` and `toml_collect`.
 */
{
    return toml_collect(toml_parse_file(filename), broadcast=broadcast);
}

func toml_collect(obj, &change, broadcast=)
/* DOCUMENT toml_collect(obj);
         or toml_collect(obj, change, broadcast=false);

     Collect contents of object `obj` into an easy to access object where TOML
     tables are stored as hash tables and TOML arrays are stored as ordinary
     arrays or, at least, as mixed vectors. The element types of the values
     stored by `obj` shall remain unchanged in the result.

     Caller variable `change` is set true if returned result is different from
     input `obj`; otherwise `change` is left unmodified.

     Keyword `broadcast` specifies whether broadcasting rules apply when
     collecting entries of `obj`.

   SEE ALSO: `toml_parse`, `toml_load`, `h_new`, and `mvect_create`.
 */
{
    if (toml_type(obj) == TOML_TABLE) {
        // Convert TOML table into a hash table.
        len = obj.len;
        tbl = h_new();
        for (i = 1; i <= len; ++i) {
            h_set, tbl, toml_key(obj, i), toml_collect(obj(i), broadcast=broadcast);
        }
        change = 1n;
        return tbl;
    }
    if (toml_type(obj) == TOML_ARRAY) {
        // Convert TOML array into a "mixed vector".
        len = obj.len;
        vec = mvect_create(len);
        for (i = 1; i <= len; ++i) {
            vec, i, obj(i);
        }
        change = 1n;
        eq_nocopy, obj, vec;
    }
    if (is_mvect(obj)) {
        // Attempt to convert "mixed vector" into a regular array.
        len = obj.len;
        common_type = -1; // common type identifier or -1 if none
        change_here = 0n; // any change in this stage?
        vec = mvect_create(len); // other mixed vector to store collected entries
        for (i = 1; i <= len; ++i) {
            local a, b;
            eq_nocopy, a, obj(i);
            eq_nocopy, b, toml_collect(a, change_here, broadcast=broadcast);
            vec, i, b;
            if (i == 1) {
                common_type = identof(b);
            } else if (identof(b) != common_type) {
                common_type = -1;
            }
        }
        if (change_here) {
            eq_nocopy, obj, vec;
            change = 1n;
        }
        if (common_type >= Y_CHAR && common_type <= Y_POINTER) {
            // Determine common dimensions.
            common_dims = dimsof(obj(1));
            common_rank = numberof(common_dims);
            compat = 1n; // dimensions are compatible?
            if (broadcast) {
                // Apply broadcasting rules to determine common dimensions.
                for (i = 2; i <= len; ++i) {
                    this_dims = dimsof(obj(i));
                    this_rank = numberof(this_dims);
                    min_rank = min(common_rank, this_rank);
                    for (j = 2; j <= min_rank; ++j) {
                        if ((this_dim = this_dims(j)) == 1) continue;
                        if ((common_dim = common_dims(j)) == this_dim) continue;
                        if (common_dim != 1) {
                            compat = 0n;
                            break;
                        }
                        common_dims(j) = this_dim;
                    }
                    if (!compat) {
                        break;
                    }
                    if (this_rank > common_rank) {
                        grow, common_dims, this_dims(common_rank+1:this_rank);
                        common_rank = this_rank;
                        common_dims(1) = common_rank - 1;
                    }
                }
            } else {
                // All entries must have the same dimensions.
                for (i = 2; i <= len; ++i) {
                    this_dims = dimsof(obj(i));
                    if (numberof(this_dims) != common_rank ||
                        nallof(this_dims == common_dims)) {
                        compat = 0n;
                        break;
                    }
                }
            }
            if (compat) {
                // Mixed vector can be converted into an ordinary array.
                common_dims(1) = common_rank - 1;
                arr = array(common_type, common_dims, len);
                for (i = 1; i <= len; ++i) {
                    arr(..,i) = obj(i);
                }
                change = 1n;
                return arr;
            }
        }
    }
    return obj;
}
