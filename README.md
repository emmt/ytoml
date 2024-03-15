# A Yorick interface to TOML files

This repository provides a plug-in to deal with [TOML
files](https://toml.io/en/) in [Yorick](http://github.com/LLNL/yorick).

`ytoml` currently uses a patched version of the C parser in
[toml-c](https://github.com/arp242/toml-c). See
[toml-c/issues/2](https://github.com/arp242/toml-c/issues/2) for a description
of the issues fixed for this plug-in. Future plans are to switch to
[tomlc99](https://github.com/cktan/tomlc99) for parsing TOML.


## Usage

If the plug-in has been properly installed, it is sufficient to use any
function of the plug-in to automatically load it. You may force the loading of
the plug-in by something like:

``` c
#include "toml.i"
```

or

``` c
require, "toml.i";
```

in your code.

To read a TOML table from a string buffer or from a file, do:

``` c
tbl = toml_parse(buffer);
tbl = toml_parse_file(filename);
```

Entries in a table can be accessed by an integer index `idx` or by a string
`key`:

``` c
val = tbl(key);
val = tbl(idx);
```

where the value `val` can be:

- a boolean represented by a Yorick's `int`: `0n` for false, `1n` for true;
- an integer represented by a Yorick's `long`;
- a floating-point represented by a Yorick's `double`;
- a string represented by a Yorick's `string`;
- a timestamp;
- a TOML table;
- a TOML array.

A TOML array is similar to a TOML table except that it can only be indexed by
integers.

The number of entries in a TOML table or array, say `obj`, is given by
`obj.len` and Yorick's indexing rules hold, that is `obj(0)` yields the last
entry, `obj(-1)` yields the before last entry and so on.

Other members are:

- `obj.len` yields the number of entries in `obj`;
- `obj.root` yields the root TOML table to which `obj` belongs to;
- `obj.is_root` yields whether `obj` is the root TOML table;

To identify the type of TOML object, call:

``` c
id = toml_type(obj);
```

which yields `1` if `obj` is a TOML table, `2` if `obj` is a TOML table, and
`0` otherwise.


## Installation

### Prerequisites

To install this plug-in, you must have [Yorick](http://github.com/LLNL/yorick)
and Git installed on your machine.


### Installation with `EasyYorick`

The easiest installation is to use
[`EasyYorick`](https://github.com/emmt/EasyYorick) for installing Yorick and
this plug-in (and many others). Assuming `EasyYorick` has been installed,
installing the `YTOML` plug-in is as simple as:

``` sh
ypkg upgrade ypkg
ypkg install ytoml
```


### Manual installation

In short, building and installing the plug-in can be as quick as:

``` sh
cd $BUILD_DIR
$SRC_DIR/configure
make
make install
```

where `$BUILD_DIR` is the build directory (at your convenience) and `$SRC_DIR`
is the source directory of the plug-in code. The build and source directories
can be the same in which case, call `./configure` to configure for building.

More detailed installation explanations are given below.

1. You must have [Yorick](http://github.com/LLNL/yorick) and Git installed on
   your machine.

2. Unpack the software code somewhere or clone the Git repository with:

   ```sh
   git clone https://github.com/emmt/ytoml
   ```

3. Configure for compilation.  There are two possibilities:

   For an **in-place build**, go to the source directory, say `$SRC_DIR`, of
   the plug-in code and run the configuration script:

   ``` sh
   cd $SRC_DIR
   ./configure
   ```

   To see the configuration options, call:

   ``` sh
   ./configure --help
   ```

   In particular the options `CPPFLAGS=...`, `CFLAGS=...`, and `LDFLAGS=...` or
   `--deplibs` may be used to specify additional options for the
   preprocessor, the compiler, and the linker.

   To compile in a **different build directory**, say `$BUILD_DIR`, create the
   build directory, go to the build directory and run the configuration script:

   ``` sh
   mkdir -p $BUILD_DIR
   cd $BUILD_DIR
   $SRC_DIR/configure
   ```

   where `$SRC_DIR` is the path to the source directory of the plug-in code.
   To see the configuration options, call:

   ``` sh
   $SRC_DIR/configure --help
   ```

4. Compile the code:

   ``` sh
   make
   ```

4. Install the plug-in in Yorick directories:

   ``` sh
   make install
   ```
