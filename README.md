# spanner-sql-udf

This repository contains a set of Spanner User-Defined Functions (UDFs) for a
number of MySQL built-in functions. Combined together with Spanner's existing
built-in functions, they provide coverage for most of MySQL's built-in
functions. These UDFs are designed to assist customers migrating applications
from MySQL to Spanner by providing definitions for MySQL built-in functions not
already supported in Spanner, reducing the effort to migrate application code
and queries.

Spanner’s support for UDFs will be available soon.

## Features

Supported list of User-Defined Functions (UDFs)

- DEGREES
- LOG2
- PI
- RADIANS
- TRUNCATE
- DATE_FORMAT
- DATEDIFF
- DAY
- DAYNAME
- DAYOFMONTH
- DAYOFWEEK
- DAYOFYEAR
- FROM_DAYS
- FROM_UNIXTIME
- HOUR
- LOCALTIME
- LOCALTIMESTAMP
- MAKEDATE
- MICROSECOND
- MINUTE
- MONTH
- MONTHNAME
- NOW
- PERIOD_ADD
- PERIOD_DIFF
- QUARTER
- SECOND
- STR_TO_DATE
- SYSDATE
- TIME
- TO_DAYS
- TO_SECONDS
- UNIX_TIMESTAMP
- UTC_DATE
- UTC_TIMESTAMP
- WEEK
- WEEKDAY
- WEEKOFYEAR
- YEAR
- BIT_LENGTH
- CHAR
- CONCAT_WS
- HEX
- INSERT
- LOCATE
- MID
- OCT
- ORD
- POSITION
- QUOTE
- REGEXP_LIKE
- REGEXP_SUBSTR
- SPACE
- STRCMP
- SUBSTRING_INDEX
- UNHEX
- SHA2
- JSON_QUOTE
- JSON_UNQUOTE
- BIN_TO_UUID
- INET_ATON
- INET_NTOA
- INET6_ATON
- INET6_NTOA
- IS_IPV4
- IS_IPV4_COMPAT
- IS_IPV4_MAPPED
- IS_IPV6
- IS_UUID
- UUID
- UUID_TO_BIN


## Installation & usage

Creating UDFs :
- Define UDFs using the CREATE FUNCTION statement within your Schema
  Definition Language (SDL).
- Functions created should be scalar, meaning they operate on data
  from a single row at a time and return one output value per row.
- Schema Constraint: Please note that UDFs cannot be created in the
  default schema. By default, the functions in this repository (or collection)
  are created in the mysql schema.

Calling UDFs
- SQL UDFs can be invoked similarly to built-in functions within your
  queries or Data Manipulation Language (DML) statements (e.g.,
  INSERT, UPDATE, or DELETE).
- Standard Invocation: To call these UDFs, the fully qualified name,
  comprising the schema name followed by the function name (e.g.,
  schema_name.function_name), is generally required.
- Simplified Invocation: Users can call UDFs by their function name
  alone if the relevant schema is configured in their search path.

Modifying UDFs
- Use the CREATE OR REPLACE FUNCTION statement to update an existing
  UDF.

Removing UDFs
- Use the DROP FUNCTION function_name statement to delete a UDF.
-
## Limitations

- **Unique Naming (No Overloading):** You cannot overload User-Defined
  Functions (UDFs). Each UDF must have a distinct name, even if its
  parameters (signature) differ from another UDF.
- **No Recursion or Circular Calls:** SQL UDFs do not support recursion
  (calling themselves) or circular call chains (being called by another
  schema object that eventually calls the original UDF).
- **Naming Conflicts with Built-in Functions:** A UDF cannot be created
  with the same name as an existing built-in Spanner function. If
  Spanner later introduces a built-in function that shares a name with
  one of your existing UDFs, your application will continue to use your
  UDF without change. However, access to the new built-in function
  will be blocked until your UDF with the conflicting name is removed
  (dropped).
- **Invocation Without SAFE. Prefix:** The SAFE. prefix cannot be used
  when calling UDFs.
- Each UDF definition is accompanied by detailed documentation, including any
  differences between the UDF and the corresponding MySQL built-in function,
  and any limitations of the UDF.

## Contribute

We are currently not accepting external code contributions to this project.

## License

[Apache License 2.0](LICENSE)