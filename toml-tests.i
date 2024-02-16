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
root = toml_parse(doc);
