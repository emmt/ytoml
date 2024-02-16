plug_dir, dirname(current_include());
include, "toml.i";
doc = ("\n" +
       "host = 'example.com'\n" +
       "port = 80\n" +
       "\n" +
       "[tbl]\n" +
       "key = 'value'\n" +
       "[tbl.sub]\n" +
       "subkey = 'subvalue'\n" +
       "ints  = [1, 2, 3]\n" +
       "mixed = [1, 'one', 1.2]\n" +
       "\n" +
       "[[aot]]\n" +
       "k = 'one'\n" +
       "[[aot]]\n" +
       "k = 'two'\n");
nerrs = 0;
ntests = 0;
root = toml_parse(doc);
if (toml_type(root) == 1) {
    ++ntests;
} else {
    ++nerrs;
    write, format="FAILURE: `%s`\n", "toml_type(root) == 1";
}
if (toml_length(root) == root.len) {
    ++ntests;
} else {
    ++nerrs;
    write, format="FAILURE: `%s`\n", "toml_length(root) == root.len";
}
keys = toml_keys(root);
if (numberof(keys) == root.len) {
    ++ntests;
} else {
    ++nerrs;
    write, format="FAILURE: `%s`\n", "numberof(keys) == root.len";
}
for (i = -1; i <= root.len; ++i) {
    if (toml_key(root, i) == keys(i)) {
        ++ntests;
    } else {
        ++nerrs;
        write, format="FAILURE: `%s` with `i = %d`\n",
            "toml_key(root, i) == keys(i))", i;
    }
}
if (toml_key(root, root.len+1) == string()) {
    ++ntests;
} else {
    ++nerrs;
    write, format="FAILURE: `%s`\n", "toml_key(root, root.len+1) == string()";
}
if (root(keys(1)) == root(1)) {
    ++ntests;
} else {
    ++nerrs;
    write, format="FAILURE: `%s`\n", "root(keys(1)) == root(1)";
}
if (root(keys(2)) == root(2)) {
    ++ntests;
} else {
    ++nerrs;
    write, format="FAILURE: `%s`\n", "root(keys(2)) == root(2)";
}

// Summary.
if (nerrs > 0) {
    write, format="%d failure(s) / %d tests\n", nerrs, ntests;
} else {
    write, format="%d tests passed (no failures)\n", ntests;
}
