# spanner-sql-udf

This repository contains a package of Spanner User-Defined Functions (UDFs) for
many MySQL built-in functions. Combined with Spanner's existing built-in
functions, these UDFs provide coverage for most of MySQL's built-in functions.
When you migrate from MySQL to Spanner, you can use these UDFs to use MySQL
built-in functions that Spanner doesn't support. This reduces the effort to
migrate your application code and queries.

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

## Install the package

-   The package consists of a batch of DDL statements that creates a MySQL
    namespace and defines UDF functions for many MySQL built-in functions.
-   Run this batch of DDL statements as you would make any other schema update.
    For example, you can cut-and-paste the
    [mysql_udfs.sql](https://github.com/googleapis/spanner-sql-udf/blob/main/mysql/mysql_udfs.sql)
    file into the Spanner Studio page and click Run.

## Customize the package

-   If you know which functions you'll need, Spanner recommends customizing the
    mysql_udfs.sql file to include those UDF functions you need.
-   If you customize the mysql_udfs.sql file, make sure that you retain the
    create schema statement or ensure that your database has an appropriate
    schema defined. Spanner does not support creating UDF functions in the
    default schema.

## Calling UDFs

You can invoke SQL UDFs similarly to built-in functions within your queries or
Data Manipulation Language (DML) statements (for example, INSERT, UPDATE, or
DELETE).

-   **Standard Invocation**: To call these UDFs, you generally need the fully
    qualified name, which comprises the schema name followed by the function
    name e.g. SELECT mysql.PI().

-   **Simplified Invocation**: You can call UDFs by their function name alone by
    configuring your udf search path. For example `ALTER DATABASE mydatabase SET
    OPTIONS(udf_search_path=['mysql']);` will configure the udf search path for
    mydatabase so that `SELECT mysql.PI()` can be simplified to `SELECT PI()`.

## Removing UDFs

-   Use the DROP FUNCTION statement to delete a UDF:

    DROP FUNCTION [function_name];

## Status of UDF package availability

-   This UDF package is Generally Available (GA) for use on Cloud Spanner.

## Limitations

-   UDF functions may have some differences from the MySQL built-in function.
    These differences, and limitations are available as comments in the
    [mysql_udfs.sql](https://github.com/googleapis/spanner-sql-udf/blob/main/mysql/mysql_udfs.sql)
    file.

## Contribute

We are currently not accepting external code contributions to this project.

## License

[Apache License 2.0](LICENSE)