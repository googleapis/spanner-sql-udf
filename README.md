# spanner-sql-udf

This repository contains a set of Spanner User-Defined Functions (UDFs) for a
number of MySQL built-in functions. Combined together with Spanner's existing
built-in functions, they provide coverage for most of MySQL's built-in
functions. These UDFs are designed to assist customers migrating applications
from MySQL to Spanner by providing definitions for MySQL built-in functions not
already supported in Spanner, reducing the effort to migrate application code
and queries.

Spanner’s support for UDFs will be available soon.

## Features & Limitations

Supported list of User-Defined Functions (UDFs)

- DAY
- DAYNAME
- DAYOFMONTH
- DAYOFWEEK
- DAYOFYEAR

Limitations:

- Each UDF definition is accompanied by detailed documentation, including any
  differences between the UDF and the corresponding MySQL built-in function, and
  any limitations of the UDF.

## Contribute

We are currently not accepting external code contributions to this project.

## License

[Apache License 2.0](LICENSE)