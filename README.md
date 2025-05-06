# spanner-sql-udf

This repository contains a set of Spanner User-Defined Functions (UDFs) for
several MySQL built-in functions. Combined with Spanner's existing built-in
functions, these UDFs provide coverage for most of MySQL's built-in functions.
These UDFs assist customers migrating applications from MySQL to Spanner by
providing definitions for MySQL built-in functions that Spanner doesn't already
support, thereby reducing the effort to migrate application code and queries.

## Features

Spanner supports the following UDFs:

- BIN_TO_UUID
- BIT_LENGTH
- CHAR
- CONCAT_WS
- DATE_FORMAT
- DATEDIFF
- DAY
- DAYNAME
- DAYOFMONTH
- DAYOFWEEK
- DAYOFYEAR
- DEGREES
- FROM_DAYS
- FROM_UNIXTIME
- HEX
- HOUR
- INET6_ATON
- INET6_NTOA
- INET_ATON
- INET_NTOA
- INSERT
- IS_IPV4
- IS_IPV4_COMPAT
- IS_IPV4_MAPPED
- IS_IPV6
- IS_UUID
- JSON_QUOTE
- JSON_UNQUOTE
- LOCALTIME
- LOCALTIMESTAMP
- LOCATE
- LOG2
- MAKEDATE
- MICROSECOND
- MID
- MINUTE
- MONTH
- MONTHNAME
- NOW
- OCT
- ORD
- PERIOD_ADD
- PERIOD_DIFF
- PI
- POSITION
- QUARTER
- QUOTE
- RADIANS
- REGEXP_LIKE
- REGEXP_SUBSTR
- SECOND
- SHA2
- SPACE
- STRCMP
- STR_TO_DATE
- SUBSTRING_INDEX
- SYSDATE
- TIME
- TO_DAYS
- TO_SECONDS
- TRUNCATE
- UNHEX
- UNIX_TIMESTAMP
- UTC_DATE
- UTC_TIMESTAMP
- UUID
- UUID_TO_BIN
- WEEK
- WEEKDAY
- WEEKOFYEAR
- YEAR

## Creating UDFs :

- Define UDFs using the CREATE FUNCTION statement within your Schema
  Definition Language (SDL).
- The UDFs you create must be scalar, meaning they operate on data from a single
  row at a time and return one output value per row.
- You cannot create UDFs in the default schema. By default, this repository (or collection) creates the functions in the mysql schema.

## Calling UDFs

- You can invoke SQL UDFs similarly to built-in functions within your queries or
  Data Manipulation Language (DML) statements (for example, INSERT, UPDATE, or
  DELETE).
- Standard Invocation: To call these UDFs, you generally need the fully qualified name, which comprises the schema name followed by the function name (for example, schema_name.function_name).
- Simplified Invocation: You can call UDFs by their function name alone if their search path includes the relevant schema.

## Modifying UDFs

- Use the CREATE OR REPLACE FUNCTION statement to update an existing
  UDF.

## Removing UDFs

- Use the DROP FUNCTION function_name statement to delete a UDF.

## Limitations

- **Unique Naming (No Overloading):** You cannot overload User-Defined
  Functions (UDFs). Each UDF must have a distinct name, even if its
  parameters (signature) differ from another UDF.
- **No Recursion or Circular Calls**: SQL UDFs do not support recursion
  (calling themselves) or circular call chains (where a schema object calls
  the UDF, and this call is part of a sequence that ultimately leads back to
  the original UDF).
- **Naming Conflicts with Built-in Functions**: You cannot create a UDF with
  the same name as an existing built-in Spanner function. If Spanner later
  introduces a built-in function that shares a name with one of your existing
  UDFs, your application continues to use your UDF without change. However,
  Spanner blocks access to the new built-in function until you remove (drop)
  your UDF with the conflicting name.
- **Invocation without the `SAFE.` prefix**: You cannot use the `SAFE.`
  prefix when calling UDFs.
- Each [UDF Definition](https://github.com/googleapis/spanner-sql-udf/blob/main/mysql/mysql_udfs.sql) is accompanied by detailed
  documentation, including any differences between the UDF and the corresponding
  MySQL built-in function, and any limitations of the UDF.

## Contribute

We are currently not accepting external code contributions to this project.

## License

[Apache License 2.0](LICENSE)