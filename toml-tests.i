plug_dir, dirname(current_include());
require, "toml.i";
require, "testing.i";
doc = ("\n" +
       "host = 'example.com'\n" +
       "port = 80\n" +
       "date = 1979-05-27T07:32:00-08:00\n" +
       "\n" +
       "[tbl]\n" +
       "key = 'value'\n" +
       "[tbl.sub]\n" +
       "subkey = 'subvalue'\n" +
       "ints  = [1, 2, 3]\n" +
       "mixed = [1, 'one', 1.2, true]\n" +
       "\n" +
       "[[aot]]\n" +
       "k = 'one'\n" +
       "[[aot]]\n" +
       "k = 'two'\n");
test_init, 1n;
root = toml_parse(doc);
test_eval, "toml_type(root) == 1";
test_eval, "toml_length(root) == root.len";
keys = toml_keys(root);
test_eval, "numberof(keys) == root.len";
for (i = -1; i <= root.len; ++i) {
    test_assert, toml_key(root, i) == keys(i),
        "TEST FAILED: `%s` with `i = %d`\n",
        "toml_key(root, i) == keys(i))", i;
}
test_eval, "toml_key(root, root.len+1) == string()";
test_eval, "root(keys(1)) == root(1)";
test_eval, "root(keys(2)) == root(2)";

// Timestamp.
ts = root("date");
test_eval, "toml_type(ts) == 3";
test_eval, "ts.kind == 'd'";
test_eval, "structof(ts.kind) == char";
test_eval, "structof(ts.year) == long";
test_eval, "structof(ts.month) == long";
test_eval, "structof(ts.day) == long";
test_eval, "structof(ts.hour) == long";
test_eval, "structof(ts.minute) == long";
test_eval, "structof(ts.second) == double";
test_eval, "structof(ts.tz) == string";

// Sub-table.
tbl = root("tbl");
test_eval, "toml_type(tbl) == 1";
test_eval, "!tbl.is_root";
test_eval, "tbl.root == root";
test_eval, "tbl.len == tbl()";

// Other sub-table.
tbl_sub = tbl("sub");
test_eval, "toml_type(tbl_sub) == 1";
test_eval, "!tbl_sub.is_root";
test_eval, "tbl_sub.root == root";
test_eval, "tbl_sub.len == tbl_sub()";

// Array of long's.
tbl_sub_ints = tbl_sub("ints");
test_eval, "toml_type(tbl_sub_ints) == 2";
test_eval, "!tbl_sub_ints.is_root";
test_eval, "tbl_sub_ints.root == root";
test_eval, "tbl_sub_ints.len == 3";
test_eval, "tbl_sub_ints.len == tbl_sub_ints()";
for (i = 1; i <= tbl_sub_ints.len; ++i) {
    test_assert, tbl_sub_ints(i) == i,
        "TEST FAILED: `%s` with `i = %d`\n",
        "tbl_sub_ints(i) == i", i;
    test_assert, structof(tbl_sub_ints(i)) == long,
        "TEST FAILED: `%s` with `i = %d`\n",
        "structof(tbl_sub_ints(i)) == long", i;
}
test_eval, "tbl_sub_ints(0) == tbl_sub_ints(tbl_sub_ints.len)";
test_eval, "tbl_sub_ints(-1) == tbl_sub_ints(tbl_sub_ints.len - 1)";
test_eval, "tbl_sub_ints(-2) == tbl_sub_ints(tbl_sub_ints.len - 2)";

// Mixed array.
tbl_sub_mix = tbl_sub("mixed");
test_eval, "toml_type(tbl_sub_mix) == 2";
test_eval, "!tbl_sub_mix.is_root";
test_eval, "tbl_sub_mix.root == root";
test_eval, "tbl_sub_mix.len == 4";
test_eval, "tbl_sub_mix.len == tbl_sub_mix()";
test_eval, "tbl_sub_mix(1) == 1";
test_eval, "structof(tbl_sub_mix(1)) == long";
test_eval, "tbl_sub_mix(2) == \"one\"";
test_eval, "structof(tbl_sub_mix(2)) == string";
test_eval, "tbl_sub_mix(3) == 1.2";
test_eval, "structof(tbl_sub_mix(3)) == double";
test_eval, "tbl_sub_mix(4) == 1n";
test_eval, "structof(tbl_sub_mix(4)) == int";
test_eval, "tbl_sub_mix(0) == tbl_sub_mix(tbl_sub_mix.len)";
test_eval, "tbl_sub_mix(-1) == tbl_sub_mix(tbl_sub_mix.len - 1)";
test_eval, "tbl_sub_mix(-2) == tbl_sub_mix(tbl_sub_mix.len - 2)";

// Format.
test_eval, "toml_format_boolean(0n) == \"false\"";
test_eval, "toml_format_boolean(1n) == \"true\"";
test_eval, "toml_format_integer(-257) == \"-257\"";
test_eval, "toml_format_float(1.0) == \"1.0\"";
test_eval, "toml_format_float(-1e-8) == \"-1e-08\"";
test_eval, "toml_format_string(\"hello, Joe\") == \"\\\"hello, Joe\\\"\"";
test_eval, "toml_format_string(\"Joe's \\\"bar\\\"\") == \"\\\"Joe's \\\\\\\"bar\\\\\\\"\\\"\"";
test_eval, "toml_format_timestamp(ts) == \"1979-05-27T07:32:00.000-08:00\"";

// Summary.
test_summary;
