gridOS runner
==

Run gridOS program, and evaluate against tests.

```
usage: gridos.jl [-h] [-v] [--fps N] [-p] [-c] prog [--skip N] [test...]

positional arguments:
  prog                  program file to execute
  test                  test files

options:
  -p,--print            print the program
  -c,--clean            purge the program of unused rules
  --fps N               animation speed
  --skip N              skip N tests
  -v,--verbose          verbose output
  -h,--help             show this help
```

Process JSON test files into plain text.

```
usage: gridos.jl [-h] input [TEST...]

positional arguments:
  test                  test files

options:
  -h,--help             show this help
```
