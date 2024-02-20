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

extern toml_timestamp;
/* DOCUMENT ts = toml_timestamp();

     `toml_timestamp()` yields a TOML timestamp with the current UTC time.

   SEE ALSO: `toml_parse`.
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

local toml_format_boolean, toml_format_float, toml_format_integer;
local toml_format_string, toml_format_timestamp;
/* DOCUMENT toml_format_boolean(b);
         or toml_format_float(f);
         or toml_format_integer(i);
         or toml_format_string(s);
         or toml_format_timestamp(t);

     `toml_format_boolean(b)` yields a string suitable to represent the boolean
     value `b` in a TOML file.

     `toml_format_float(f)` yields a string suitable to represent the
     floating-point value `f` in a TOML file.

     `toml_format_integer(i)` yields a string suitable to represent the integer
     value `i` in a TOML file.

     `toml_format_string(s)` yields a string suitable to represent the scalar
     string `s` in a TOML file.

     `toml_format_timsetamp(t)` yields a string suitable to represent the
     timestamp `t` in a TOML file.

     For efficiency, it is not checked that the argument is of the correct type:
     • `b` is a scalar int;
     • `i` is a scalar integer;
     • `f` is a scalar float/double;
     • `s` is a scalar string;
     • `t` is a TOML timestamp.

   SEE ALSO: toml_parse.
 */

func toml_format_boolean(b)
{
    return b ? "true" : "false";
}

func toml_format_integer(i)
{
    return swrite(format="%ld", i);
}

func toml_format_float(f)
{
    t = ieee_test(f);
    if (t != 0) {
        if (t == -1) return "-inf";
        if (t == +1) return "+inf";
        if (t == 3 || t == 5) return "nan";
    }
    str = swrite(format="%.17g", f);
    return strglob("*[.eE]*", str) ? str : str + ".0";
}

_TOML_ESC = array(int, 256);
_TOML_ESC(1 + '"') = 1n;
_TOML_ESC(1 + '\b') = 1n;
_TOML_ESC(1 + '\t') = 1n;
_TOML_ESC(1 + '\n') = 1n;
_TOML_ESC(1 + '\f') = 1n;
_TOML_ESC(1 + '\r') = 1n;
_TOML_ESC(1 + '\\') = 1n;
func toml_format_string(s)
{
    src = strchar(s);
    len = numberof(src);
    dst = array(char, 2*len + 2);
    j = 1;
    dst(j) = '"';
    for (i = 1; i < len /* skip last '\0' */; ++i) {
        c = src(i);
        if (_TOML_ESC(1 + c)) {
            dst(++j) = '\\';
        }
        dst(++j) = c;
    }
    dst(++j) = '"';
    return strchar(dst(1:j));
}

func toml_format_timestamp(t)
{
    kind = t.kind;
    if (kind == 'd') {
        // offset datetime
        return swrite(format="%d-%02d-%02dT%02d:%02d:%06.3f%s",
                      t.year, t.month, t.day,
                      t.hour, t.minute, t.second, t.tz);
    } else if (kind == 'l') {
        // local datetime
        return swrite(format="%d-%02d-%02dT%02d:%02d:%06.3f",
                      t.year, t.month, t.day,
                      t.hour, t.minute, t.second);
    } else if (kind == 'D') {
        // local date
        return swrite(format="%d-%02d-%02d", t.year, t.month, t.day);
    } else if (kind == 't') {
        // local time
        return swrite(format="%02d:%06.3f", t.hour, t.minute, t.second);
    } else {
        error, "invalid timestamp kind";
    }
}
