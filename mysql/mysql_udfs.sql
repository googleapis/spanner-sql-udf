-- Copyright 2025 Google LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- Defining schema that will contain all functions.
CREATE OR REPLACE SCHEMA mysql;

-- [START MYSQL_UDF_NUMERIC_DEGREES]
-- NAME : DEGREES
-- TYPE : NUMERIC
-- DESCRIPTION : Convert radians to degrees.
-- RETURN_TYPE : FLOAT64
-- PARAMETERS : x - The input angle in radians (FLOAT64).
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS : May overflow with very large values (greater than 1e300)
-- [END MYSQL_UDF_NUMERIC_DEGREES]
CREATE OR REPLACE FUNCTION mysql.DEGREES(x FLOAT64)
RETURNS FLOAT64
AS (
  x / SAFE.ACOS(0) * 90
);

-- NAME : LOG2
-- TYPE : NUMERIC
-- DESCRIPTION : Return the base-2 logarithm of the argument.  Returns NULL if x is out of range.
-- RETURN_TYPE : FLOAT64
-- PARAMETERS : x - The input value (FLOAT64).
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.LOG2(x FLOAT64)
RETURNS FLOAT64
AS (
  SAFE.IF(x > 0, SAFE.LOG(x, 2), NULL)
);

-- NAME : PI
-- TYPE : NUMERIC
-- DESCRIPTION : Return the value of pi.
-- RETURN_TYPE : FLOAT64
-- PARAMETERS :
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.PI()
RETURNS FLOAT64
AS (
  SAFE.ACOS(0) * 2.0
);

-- NAME : RADIANS
-- TYPE : NUMERIC
-- DESCRIPTION : Return argument converted to radians
-- RETURN_TYPE : FLOAT64
-- PARAMETERS : x - The input angle in degrees (FLOAT64).
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.RADIANS(x FLOAT64)
RETURNS FLOAT64
AS (
  (x / 90) * SAFE.ACOS(0)
);

-- NAME : TRUNCATE
-- TYPE : NUMERIC
-- DESCRIPTION : Truncate to specified number of decimal places.
-- RETURN_TYPE : FLOAT64
-- PARAMETERS :
--    x - The value to truncate (FLOAT64).
--    d - The number of decimal places to preserve (INT64).
-- DIFFERENCE FROM MYSQL : MySQL only has a 2-arg version of TRUNCATE.
-- LIMITATIONS : `TRUNCATE` is a reserved keyword in Spanner DDL.  When used in DDL (such as
-- generated columns), the function's name must be quoted.
CREATE OR REPLACE FUNCTION mysql.`TRUNCATE`(x FLOAT64, d INT64)
RETURNS FLOAT64
AS (
  SAFE.TRUNC(x, d)
);

-- NAME : DATE_FORMAT
-- TYPE : DATE AND TIME
-- DESCRIPTION : Format date as specified
-- RETURN_TYPE : STRING
-- PARAMETERS :
--    d - The TIMESTAMP value to format.
--    format - The format string.
-- DIFFERENCE FROM MYSQL : This implementation supports a subset of MySQL's DATE_FORMAT specifiers.
-- Several specifiers are explicitly disallowed and will raise an error.  Some Spanner-specific
-- specifiers that are not available in MySQL may be supported here.
-- LIMITATIONS :
--    - The following format specifiers are not supported:
--      %c, %D, %f, %h, %i, %M, %r, %s, %u, %V, %W, %X, %x
--    - When applying time-related format specifiers to a date, Spanner ignores the specifiers;
--      MySQL substitutes in values from a default time value.
--    - There may be subtle differences in how Spanner handles format specifiers that MySQL ignores.
--    - MySQL supports either a DATE or a TIMESTAMP argument depending on the contents of `format`.
--      Spanner only supports a TIMESTAMP argument.
CREATE OR REPLACE FUNCTION mysql.DATE_FORMAT(d TIMESTAMP, format STRING)
RETURNS STRING
AS (
  SAFE.FORMAT_TIMESTAMP(
    CASE
      WHEN SAFE.REGEXP_CONTAINS(format, '(^|[^%])%[cDfhciMrsuVWXx]')
        THEN
          ERROR(
            SAFE.CONCAT(
              '%',
              SAFE.REGEXP_EXTRACT(format, '(^|[^%])%[cDfhciMrsuVWXx]'),
              ' format specifier is not supported'))
      ELSE format
      END,
    d)
);

-- NAME : DATEDIFF
-- TYPE : TIMESTAMP
-- DESCRIPTION : Subtract two dates, returning the number of days between them.
-- RETURN_TYPE : INT64
-- PARAMETERS :
--    d1 - The first TIMESTAMP value.
--    d2 - The second TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : This implementation only accepts TIMESTAMP.  MySQL also accepts DATE or
--    DATETIME values.
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.DATEDIFF(d1 TIMESTAMP, d2 TIMESTAMP)
RETURNS INT64
AS (
  SAFE.TIMESTAMP_DIFF(d1, d2, DAY)
);

-- NAME : DAY
-- TYPE : DATE AND TIME
-- DESCRIPTION : Synonym for DAYOFMONTH(). Returns the day of the month (1-31) from a TIMESTAMP
-- value.
-- RETURN_TYPE : INT64
-- PARAMETERS : ts - The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : MySQL additionally supports both DATE and DATETIME values for these
--    functions.  Only the TIMESTAMP implementation is provided here.
-- LIMITATIONS :
-- 1. This function handles invalid timestamps differently than MySQL.  MySQL returns
--    NULL, while this function throws an error.  For instance, SELECT mysql.DAY('2007-12-32') will
--    produce an error.
-- 2. This function does not support the "zero date", whereas MySQL does.  The query
--    SELECT mysql.DAY('0000-00-00') will generate an error in Spanner, but will return NULL in
--    MySQL.
CREATE OR REPLACE FUNCTION mysql.DAY(ts TIMESTAMP)
RETURNS INT64
AS (
  EXTRACT(DAY FROM ts)
);

-- NAME : DAYNAME
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the name of the weekday
-- RETURN_TYPE : STRING
-- PARAMETERS : ts - The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : MySQL additionally supports both DATE and DATETIME values for these
--    functions.  Only the TIMESTAMP implementation is provided here.
-- LIMITATIONS : None -- but note that if a timestamp is provided as a string literal, a cast will
-- be inserted, and Spanner's cast function errors with an invalid string where MySQL's returns
-- NULL.
CREATE OR REPLACE FUNCTION mysql.DAYNAME(ts TIMESTAMP)
RETURNS STRING
AS (
  SAFE.FORMAT_TIMESTAMP('%A', ts)
);

-- NAME : DAYOFMONTH
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the day of the month (0-31)
-- RETURN_TYPE : INT64
-- PARAMETERS : ts - The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : Date/time UDFs in Spanner operate solely on TIMESTAMP values. MySQL
--    supports both DATE and DATETIME values.
-- LIMITATIONS : This function handles invalid timestamps differently than MySQL.  MySQL returns
--    NULL, while this function throws an error.
CREATE OR REPLACE FUNCTION mysql.DAYOFMONTH(ts TIMESTAMP)
RETURNS INT64
AS (
  EXTRACT(DAY FROM ts)
);

-- NAME : DAYOFWEEK
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the weekday index of the argument
-- RETURN_TYPE : INT64
-- PARAMETERS : ts - The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : Date/time UDFs in Spanner operate solely on TIMESTAMP values. MySQL
--    supports both DATE and DATETIME values.
-- LIMITATIONS : None -- but note that if a timestamp is provided as a string literal, a cast will
-- be inserted, and Spanner's cast function errors with an invalid string where MySQL's returns
-- NULL.
CREATE OR REPLACE FUNCTION mysql.DAYOFWEEK(ts TIMESTAMP)
RETURNS INT64
AS (
  CAST(SAFE.FORMAT_TIMESTAMP('%w', ts) AS INT64) + 1
);

-- NAME : DAYOFYEAR
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the day of the year (1-366)
-- RETURN_TYPE : INT64
-- PARAMETERS : ts - The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : Date/time UDFs in Spanner operate solely on TIMESTAMP values. MySQL
--    supports both DATE and DATETIME values.
-- LIMITATIONS : None -- but note that if a timestamp is provided as a string literal, a cast will
-- be inserted, and Spanner's cast function errors with an invalid string where MySQL's returns
-- NULL.
CREATE OR REPLACE FUNCTION mysql.DAYOFYEAR(ts TIMESTAMP)
RETURNS INT64
AS (
  CAST(SAFE.FORMAT_TIMESTAMP('%j', ts) AS INT64)
);

-- NAME : FROM_DAYS
-- TYPE : DATE AND TIME
-- DESCRIPTION : Convert a day number to a date
-- RETURN_TYPE : DATE
-- PARAMETERS : n - The number of days since 1970-01-01 (INT64).
-- DIFFERENCE FROM MYSQL : Spanner does not support dates before 0001-01-01, which corresponds to
--    FROM_DAYS(366).
-- LIMITATIONS: Use FROM_DAYS() with caution on old dates. It is not intended for use with values
--    that precede the advent of the Gregorian calendar (1582).
CREATE OR REPLACE FUNCTION mysql.FROM_DAYS(n INT64)
RETURNS DATE
AS (
  SAFE.DATE_ADD('0001-01-01', INTERVAL (n - 366) DAY)
);

-- NAME : FROM_UNIXTIME
-- TYPE : DATE AND TIME
-- DESCRIPTION : Format Unix timestamp as a date
-- RETURN_TYPE : TIMESTAMP
-- PARAMETERS : n - The number of seconds since the Unix epoch (FLOAT64).
-- DIFFERENCE FROM MYSQL : The function supports larger UNIX timestamp values than MySQL, up to
--    253402300799 (corresponding to the timestamp 9999-12-31 23:59:59 UTC). It also supports
--    negative UNIX timestamp values (MySQL's FROM_UNIXTIME supports only non-negative values).
--    Always uses a timezone of UTC, rather than the session timezone as in MySQL.
-- LIMITATIONS : The UDF supports only the one-argument version of FROM_UNIXTIME.
CREATE OR REPLACE FUNCTION mysql.FROM_UNIXTIME(n FLOAT64)
RETURNS TIMESTAMP
AS (
  -- IF a number is far too big to fit into a timestamp, return NULL to avoid math overflow errors.
  SAFE.IF(
    SAFE.ABS(n) > 1000000000000,
    NULL,
    SAFE.TIMESTAMP_MICROS(CAST(n * 1000000 AS INT64)))
);

-- NAME : HOUR
-- TYPE : DATE AND TIME
-- DESCRIPTION : Extract the hour
-- RETURN_TYPE : INT64
-- PARAMETERS : ts - The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : Date/time UDFs in Spanner operate solely on TIMESTAMP values. MySQL
--    supports both DATE and DATETIME values.
-- LIMITATIONS : This function handles invalid timestamps differently than MySQL.  MySQL returns
--    NULL, while this function throws an error.
CREATE OR REPLACE FUNCTION mysql.HOUR(ts TIMESTAMP)
RETURNS INT64
AS (
  EXTRACT(HOUR FROM ts)
);

-- NAME : LOCALTIME
-- TYPE : TIMESTAMP
-- DESCRIPTION : Synonym for NOW(). Returns the TIMESTAMP at which the query statement that contains
--     this function started to execute.
-- RETURN_TYPE : TIMESTAMP
-- PARAMETERS :
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.LOCALTIME()
RETURNS TIMESTAMP
AS (
  SAFE.CURRENT_TIMESTAMP()
);

-- NAME : LOCALTIMESTAMP
-- TYPE : TIMESTAMP
-- DESCRIPTION : Returns the TIMESTAMP at which the query statement that contains this
--    function started to execute.
-- RETURN_TYPE : TIMESTAMP
-- PARAMETERS :
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.LOCALTIMESTAMP()
RETURNS TIMESTAMP
AS (
  SAFE.CURRENT_TIMESTAMP()
);

-- NAME : MAKEDATE
-- TYPE : DATE AND TIME
-- DESCRIPTION : Create a date from the year and day of year
-- RETURN_TYPE : DATE
-- PARAMETERS :
--    y - The year (INT64).
--    d - The day of the year (INT64).
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.MAKEDATE(y INT64, d INT64)
RETURNS DATE
AS (
  SAFE.IF(
    d > 0,
    SAFE.DATE_ADD(SAFE.DATE(y, 1, 1), INTERVAL (d - 1) DAY),
    NULL)
);

-- NAME : MICROSECOND
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the microseconds from argument
-- RETURN_TYPE : INT64
-- PARAMETERS : ts - The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : Date/time UDFs in Spanner operate solely on TIMESTAMP values. MySQL supports both DATE and DATETIME values.
-- LIMITATIONS : This function handles invalid timestamps differently than MySQL.  MySQL returns
--    NULL, while this function throws an error.
CREATE OR REPLACE FUNCTION mysql.MICROSECOND(ts TIMESTAMP)
RETURNS INT64
AS (
  EXTRACT(MICROSECOND FROM ts)
);

-- NAME : MINUTE
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the minute from the argument
-- RETURN_TYPE : INT64
-- PARAMETERS : ts - The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : Date/time UDFs in Spanner operate solely on TIMESTAMP values. MySQL supports both DATE and DATETIME values.
-- LIMITATIONS : This function handles invalid timestamps differently than MySQL.  MySQL returns
--    NULL, while this function throws an error.
CREATE OR REPLACE FUNCTION mysql.MINUTE(ts TIMESTAMP)
RETURNS INT64
AS (
  EXTRACT(MINUTE FROM ts)
);

-- NAME : MONTH
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the month from the date passed
-- RETURN_TYPE : INT64
-- PARAMETERS : ts - The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : Date/time UDFs in Spanner operate solely on TIMESTAMP values. MySQL supports both DATE and DATETIME values.
-- LIMITATIONS :  This function handles invalid timestamps differently than MySQL.  MySQL returns
--    NULL, while this function throws an error.
CREATE OR REPLACE FUNCTION mysql.MONTH(ts TIMESTAMP)
RETURNS INT64
AS (
  EXTRACT(MONTH FROM ts)
);

-- NAME : MONTHNAME
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the name of the month
-- RETURN_TYPE : STRING
-- PARAMETERS : ts - The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : Date/time UDFs in Spanner operate solely on TIMESTAMP values. MySQL supports both DATE and DATETIME values.
-- LIMITATIONS : None -- but note that if a timestamp is provided as a string literal, a cast will
-- be inserted, and Spanner's cast function errors with an invalid string where MySQL's returns
-- NULL.
CREATE OR REPLACE FUNCTION mysql.MONTHNAME(ts TIMESTAMP)
RETURNS STRING
AS (
  SAFE.FORMAT_TIMESTAMP('%B', ts)
);

-- NAME : NOW
-- TYPE : TIMESTAMP
-- DESCRIPTION : Returns the TIMESTAMP at which the query statement that contains this
--    function started to execute.
-- RETURN_TYPE : TIMESTAMP
-- PARAMETERS :
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.NOW()
RETURNS TIMESTAMP
AS (
  SAFE.CURRENT_TIMESTAMP()
);

-- NAME : PERIOD_ADD
-- TYPE : DATE AND TIME
-- DESCRIPTION : Add a period to a year-month
-- RETURN_TYPE : INT64
-- PARAMETERS :
--    p - The period (INT64).
--    n - The number of months to add (INT64).
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.PERIOD_ADD(p INT64, n INT64)
RETURNS INT64
AS (
  CASE
    WHEN p < 0
      THEN
        ERROR("PERIOD_ADD: Negative period not supported")
    WHEN SAFE.MOD(p, 100) < 1 OR SAFE.MOD(p, 100) > 12
      THEN
        ERROR("PERIOD_ADD: Month component of period must be between 1 and 12")
    ELSE
      WITH(
        years_part AS SAFE.DIV(p, 100),
        years AS CASE
            -- Dates like 1/1/18 assume 2018
            WHEN years_part < 70 THEN 2000 + years_part
            -- Dates like 1/1/98 assume 1998
            WHEN years_part <= 99 THEN 1900 + years_part
            -- Dates with more than 2 digits assume that the fully-qualified year is provided
            ELSE years_part
            END,
        months AS SAFE.MOD(p, 100),
        CAST(
          SAFE.FORMAT_DATE(
            '%Y%m',
            SAFE.DATE_ADD(
              SAFE.DATE(years, months, 1),
              INTERVAL n MONTH))
          AS INT64))
    END
);

-- NAME : PERIOD_DIFF
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the number of months between periods
-- RETURN_TYPE : INT64
-- PARAMETERS :
--    p1 - The first period (INT64).
--    p2 - The second period (INT64).
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.PERIOD_DIFF(p1 INT64, p2 INT64)
RETURNS INT64
AS (
  CASE
    WHEN p1 < 0 OR p2 < 0
      THEN
        ERROR("PERIOD_DIFF: Negative period not supported")
    ELSE
      WITH(
        years1_part AS SAFE.DIV(p1, 100),
        years1 AS CASE
            -- Dates like 1/1/18 assume 2018
            WHEN years1_part < 70 THEN 2000 + years1_part
            -- Dates like 1/1/98 assume 1998
            WHEN years1_part <= 99 THEN 1900 + years1_part
            -- Dates with more than 2 digits assume that the fully-qualified year is provided
            ELSE years1_part
            END,
        months1 AS SAFE.MOD(p1, 100),
        years2_part AS SAFE.DIV(p2, 100),
        years2 AS CASE
            -- Dates like 1/1/18 assume 2018
            WHEN years2_part < 70 THEN 2000 + years2_part
            -- Dates like 1/1/98 assume 1998
            WHEN years2_part <= 99 THEN 1900 + years2_part
            -- Dates with more than 2 digits assume that the fully-qualified year is provided
            ELSE years2_part
            END,
        months2 AS SAFE.MOD(p2, 100),
        period_to_date1 AS SAFE.DATE(years1, months1, 1),
        period_to_date2 AS SAFE.DATE(years2, months2, 1),
        CASE
          WHEN months1 < 1 OR months1 > 12
            THEN
              ERROR("PERIOD_DIFF: Invalid first period, months out of range")
          WHEN months2 < 1 OR months2 > 12
            THEN
              ERROR("PERIOD_DIFF: Invalid second period, months out of range")
          ELSE
            SAFE.DATE_DIFF(period_to_date1, period_to_date2, MONTH)
          END)
    END
);

-- NAME : QUARTER
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the quarter from a date argument
-- RETURN_TYPE : INT64
-- PARAMETERS : ts - The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : Date/time UDFs in Spanner operate solely on TIMESTAMP values. MySQL
--    supports both DATE and DATETIME values.
-- LIMITATIONS : This function handles invalid timestamps differently than MySQL. MySQL returns NULL,
--    while this function throws an error.
CREATE OR REPLACE FUNCTION mysql.QUARTER(ts TIMESTAMP)
RETURNS INT64
AS (
  EXTRACT(QUARTER FROM ts)
);

-- NAME : SECOND
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the second (0-59)
-- RETURN_TYPE : INT64
-- PARAMETERS : ts - The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : Date/time UDFs in Spanner operate solely on TIMESTAMP values. MySQL
--    supports both DATE and DATETIME values.
-- LIMITATIONS : This function handles invalid timestamps differently than MySQL. MySQL returns NULL,
--    while this function throws an error.
CREATE OR REPLACE FUNCTION mysql.SECOND(ts TIMESTAMP)
RETURNS INT64
AS (
  EXTRACT(SECOND FROM ts)
);

-- NAME : STR_TO_DATE
-- TYPE : DATE AND TIME
-- DESCRIPTION : Convert a string to a date
-- RETURN_TYPE : TIMESTAMP
-- PARAMETERS :
--    s - The date string.
--    format - The format string.
-- DIFFERENCE FROM MYSQL : Supports larger TIMESTAMP values than MySQL, up to 9999-12-31 23:59:59 UTC
-- LIMITATIONS :
--    - The following format specifiers are not supported:
--      %c, %D, %f, %h, %i, %M, %r, %s, %u, %V, %W, %X, %x.
--    - There may be subtle differences in how Spanner handles format specifiers
--      that MySQL ignores.
--    - Always returns a TIMESTAMP, not a DATE, whether `format` contains time parts or not.
CREATE OR REPLACE FUNCTION mysql.STR_TO_DATE(s STRING, format STRING)
RETURNS TIMESTAMP
AS (
  SAFE.PARSE_TIMESTAMP(
    CASE
      WHEN SAFE.REGEXP_CONTAINS(s, '[^%]%[cDfhciMrsuVWXx]')
        THEN
          ERROR(
            SAFE.CONCAT(
              '%',
              SAFE.REGEXP_EXTRACT(s, '[^%]%[cDfhciMrsuVWXx]'),
              ' format specifier is not supported'))
      ELSE format
      END,
    s)
);

-- NAME : SYSDATE
-- TYPE : DATE AND TIME
-- DESCRIPTION : Returns the TIMESTAMP at which the query statement that contains this
--    function started to execute.
-- RETURN_TYPE : TIMESTAMP
-- PARAMETERS :
-- DIFFERENCE FROM MYSQL : This UDF isn't an exact match for MySQL's SYSDATE: the UDF returns the
--    time at which the statement started to execute, but MySQL's SYSDATE returns the current time
--    at which the SYSDATE call executed.
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.SYSDATE()
RETURNS TIMESTAMP
AS (
  SAFE.CURRENT_TIMESTAMP()
);

-- NAME : TIME
-- TYPE : DATE AND TIME
-- DESCRIPTION : Extract the time portion of the expression passed.
-- RETURN_TYPE : STRING
-- PARAMETERS : ts - The input timestamp.
-- DIFFERENCE FROM MYSQL : Date/time UDFs in Spanner operate solely on TIMESTAMP values.
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.TIME(ts TIMESTAMP)
RETURNS STRING
AS (
  SAFE.FORMAT_TIMESTAMP('%H:%M:%E*S', ts)
);

-- NAME : TO_DAYS
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the date argument converted to days
-- RETURN_TYPE : INT64
-- PARAMETERS : d - The input DATE.
-- DIFFERENCE FROM MYSQL :  The epoch is different.  MySQL uses 0000-00-00 as day zero. This
--    function uses 1970-01-01 and adjusts accordingly.
-- LIMITATIONS : Use with caution on old dates.  Behavior for dates before 1970-01-01 may differ
--    from MySQL.
CREATE OR REPLACE FUNCTION mysql.TO_DAYS(d DATE)
RETURNS INT64
AS (
  SAFE.DATE_DIFF(d, '0001-01-01', DAY) + 366
);

-- NAME : TO_SECONDS
-- TYPE : DATE AND TIME
-- DESCRIPTION: Return the date or datetime argument converted to seconds since Year 0
-- RETURN_TYPE : INT64
-- PARAMETERS : ts - The input TIMESTAMP.
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS : Use with caution on old dates.
CREATE OR REPLACE FUNCTION mysql.TO_SECONDS(ts TIMESTAMP)
RETURNS INT64
AS (
  SAFE.TIMESTAMP_DIFF(ts, SAFE.TIMESTAMP('0001-01-01', 'UTC'), SECOND) + 31622400
);

-- NAME : UNIX_TIMESTAMP
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return a Unix timestamp
-- RETURN_TYPE : INT64
-- PARAMETERS : ts - The input TIMESTAMP.
-- DIFFERENCE FROM MYSQL : Supports larger TIMESTAMP values than MySQL, up to 9999-12-31 23:59:59 UTC
-- LIMITATIONS : Zero-argument version of UNIX_TIMESTAMP() is not supported.
CREATE OR REPLACE FUNCTION mysql.UNIX_TIMESTAMP(ts TIMESTAMP)
RETURNS INT64
AS (
  SAFE.UNIX_SECONDS(ts)
);

-- NAME : UTC_DATE
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the current UTC date
-- RETURN_TYPE : DATE
-- PARAMETERS :
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.UTC_DATE()
RETURNS DATE
AS (
  SAFE.CURRENT_DATE('UTC')
);

-- NAME : UTC_TIMESTAMP
-- TYPE : DATE AND TIME
-- DESCRIPTION : Returns the TIMESTAMP at which the query statement that contains this
--    function started to execute.
-- RETURN_TYPE : TIMESTAMP
-- PARAMETERS :
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.UTC_TIMESTAMP()
RETURNS TIMESTAMP
AS (
  SAFE.CURRENT_TIMESTAMP()
);

-- NAME : WEEK
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the week number
-- RETURN_TYPE : INT64
-- PARAMETERS : ts - The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : Date/time UDFs in Spanner operate solely on TIMESTAMP values. MySQL
--    supports both DATE and DATETIME values.  MySQL's WEEK() function takes an optional mode
--    argument, controlling the first day of the week, and whether the range is 0-53 or 1-53.
--    This UDF does not support a mode argument and always returns the week number in range 0-53
--    with first day of week as Sunday. This corresponds to MySQL's 'mode 0' behaviour,
--    the default behaviour for MySQL.
-- LIMITATIONS : This function handles invalid timestamps differently than MySQL. MySQL returns NULL,
--    while this function throws an error.
CREATE OR REPLACE FUNCTION mysql.WEEK(ts TIMESTAMP)
RETURNS INT64
AS (
  EXTRACT(WEEK FROM ts)
);

-- NAME : WEEKDAY
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the weekday index.
-- RETURN_TYPE : INT64
-- PARAMETERS : ts- The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : Date/time UDFs in Spanner operate solely on TIMESTAMP values. MySQL
--    supports both DATE and DATETIME values. MySQL WEEKDAY() returns 0 for Monday, while
--    Spanner's DAYOFWEEK returns 2.  The function adjusts for this difference.
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.WEEKDAY(ts TIMESTAMP)
RETURNS INT64
AS (
  WITH(
    day AS EXTRACT(DAYOFWEEK FROM ts),
    SAFE.IF(day = 1, 6, day - 2))
);

-- NAME : WEEKOFYEAR
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the calendar week of the date (1-53)
-- RETURN_TYPE : INT64
-- PARAMETERS : ts - The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : Date/time UDFs in Spanner operate solely on TIMESTAMP values. MySQL
--    supports both DATE and DATETIME values.
-- LIMITATIONS : This function handles invalid timestamps differently than MySQL.  MySQL returns
--    NULL, while this function throws an error.
CREATE OR REPLACE FUNCTION mysql.WEEKOFYEAR(ts TIMESTAMP)
RETURNS INT64
AS (
  EXTRACT(ISOWEEK FROM ts)
);

-- NAME : YEAR
-- TYPE : DATE AND TIME
-- DESCRIPTION : Return the year
-- RETURN_TYPE : INT64
-- PARAMETERS : ts - The input TIMESTAMP value.
-- DIFFERENCE FROM MYSQL : Date/time UDFs in Spanner operate solely on TIMESTAMP values. MySQL
--    supports both DATE and DATETIME values.
-- LIMITATIONS : This function handles invalid timestamps differently than MySQL.  MySQL returns
--    NULL, while this function throws an error.
CREATE OR REPLACE FUNCTION mysql.YEAR(ts TIMESTAMP)
RETURNS INT64
AS (
  EXTRACT(YEAR FROM ts)
);

-- NAME : BIT_LENGTH
-- TYPE : STRING
-- DESCRIPTION : Return length of string in bits.
-- RETURN_TYPE : INT64
-- PARAMETERS : str - The input string.
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.BIT_LENGTH(str STRING)
RETURNS INT64
AS (
  8 * SAFE.BYTE_LENGTH(str)
);

-- NAME: CHAR
-- TYPE: STRING
-- DESCRIPTION: Interprets the argument as an integer and returns a byte string consisting of the
--    character given by the code value of that integer. Arguments larger than 255 are converted
--    into multiple result bytes e.g. CHAR(256) is equivalent to CHAR(1,0).
-- RETURN_TYPE: BYTES
-- PARAMETERS: n - The integer to convert to a byte character
-- DIFFERENCE FROM MYSQL: This function does not support the USING clause and only accepts single
--    integer inputs.  MySQL's CHAR() supports multiple integer arguments and a USING clause to
--    specify encoding.
-- LIMITATIONS: Only handles the single argument case. Does not support the USING clause.
CREATE OR REPLACE FUNCTION mysql.CHAR(n INT64)
RETURNS BYTES
AS (
  SAFE.IFNULL(
    SAFE.FROM_HEX(
      SAFE.FORMAT(
        '%x',
        SAFE.IF(
          n < 0,
          SAFE.MOD(9223372036854775807 + n + 1, 4294967296),
          SAFE.MOD(n, 4294967296)))),
    b'')
);

-- NAME : CONCAT_WS
-- TYPE : STRING
-- DESCRIPTION : Return concatenate with separator.
-- RETURN_TYPE : STRING
-- PARAMETERS :
--   sep - The separator string.
--   str1 - The first string.
--   str2 - The second string.
-- DIFFERENCE FROM MYSQL : Similar to CONCAT, MySQL converts args to strings, but Spanner doesn’t.
-- LIMITATIONS : Only supports two strings besides the separator.  MySQL's CONCAT_WS takes a
-- variable number of arguments.
CREATE OR REPLACE FUNCTION mysql.CONCAT_WS(sep STRING, str1 STRING, str2 STRING)
RETURNS STRING
AS (
  SAFE.ARRAY_TO_STRING([str1, str2], sep)
);

-- NAME : HEX
-- TYPE : STRING
-- DESCRIPTION : Return the hexadecimal representation of str.
-- RETURN_TYPE : STRING
-- PARAMETERS : str - The input string.
-- DIFFERENCE FROM MYSQL : Only the `STRING` overload is provided.
-- LIMITATIONS : Only handles string input.  Does not support numeric input.
CREATE OR REPLACE FUNCTION mysql.HEX(str STRING)
RETURNS STRING
AS (
  SAFE.TO_HEX(CAST(str AS BYTES))
);

-- NAME : INSERT
-- TYPE : STRING
-- DESCRIPTION : Insert substring at specified position up to specified number of characters.
-- RETURN_TYPE : STRING
-- PARAMETERS :
--    str - The original string.
--    pos - The starting position for insertion (1-based).
--    len - The number of characters to replace.
--    newstr - The string to insert.
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS : `INSERT` is a keyword in Spanner DDL.  If this function is used in DDL, for example
--    in generated columns, its name must be quoted.
CREATE OR REPLACE FUNCTION mysql.`INSERT`(str STRING, pos INT64, len INT64, newstr STRING)
RETURNS STRING
AS (
  SAFE.IF(
    pos < 1 OR pos > LENGTH(str),
    str,
    SAFE.CONCAT(SAFE.SUBSTR(str, 1, pos - 1), newstr, SAFE.SUBSTR(str, pos + len)))
);

-- NAME : LOCATE
-- TYPE : STRING
-- DESCRIPTION : Return the position of the first occurrence of substring. Case insensitive.
-- RETURN_TYPE : INT64
-- PARAMETERS :
--    substr - The substring to search for.
--    str - The string to be searched.
-- DIFFERENCE FROM MYSQL : MySQL's LOCATE() has a three-argument version.  This UDF supports only
--    the two-argument version.
-- LIMITATIONS : Does not support the three-argument version of MySQL's LOCATE().
CREATE OR REPLACE FUNCTION mysql.LOCATE(substr STRING, str STRING)
RETURNS INT64
AS (
  SAFE.STRPOS(SAFE.LOWER(str), SAFE.LOWER(substr))
);

-- NAME : MID
-- TYPE : STRING
-- DESCRIPTION : Synonym for SUBSTRING.
-- RETURN_TYPE : STRING
-- PARAMETERS :
--    str - The input string.
--    pos - The starting position (1-based).
--    len - The number of characters to return.
-- DIFFERENCE FROM MYSQL :  MySQL has versions with infix operators FROM and FOR, which we don't
--    support.
-- LIMITATIONS : Does not support the two argument version of MySQL's MID, nor the infix operators
--    FROM and FOR.
CREATE OR REPLACE FUNCTION mysql.MID(str STRING, pos INT64, len INT64)
RETURNS STRING
AS (
  SAFE.IF(pos < 1, '', SAFE.SUBSTRING(str, pos, len))
);

-- NAME : OCT
-- TYPE : STRING
-- DESCRIPTION : Return a string containing octal representation of a number.
-- RETURN_TYPE : STRING
-- PARAMETERS : n - The input number.
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.OCT(n INT64)
RETURNS STRING
AS (
  SAFE.FORMAT('%o', n)
);

-- NAME : ORD
-- TYPE : STRING
-- DESCRIPTION : Return character code for leftmost character of the argument.
-- RETURN_TYPE : INT64
-- PARAMETERS : expr - The input string.
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.ORD(expr STRING)
RETURNS INT64
AS (
  SAFE.IF(
    expr = '',
    0,
    CAST(SAFE.CONCAT('0x', SAFE.TO_HEX(CAST(SAFE.SUBSTRING(expr, 1, 1) AS BYTES))) AS INT64))
);

-- NAME : POSITION
-- TYPE : STRING
-- DESCRIPTION : Synonym for LOCATE(). Returns the starting position of the first occurrence of substring.
-- RETURN_TYPE : INT64
-- PARAMETERS :
--    substr - The substring to search for.
--    str - The string to search within.
-- DIFFERENCE FROM MYSQL :  MySQL's POSITION function uses special syntax: `POSITION(substr IN
--    str)`. This UDF uses standard function-call syntax.
-- LIMITATIONS : Uses function call syntax instead of the `IN` keyword.
CREATE OR REPLACE FUNCTION mysql.POSITION(substr STRING, str STRING)
RETURNS INT64
AS (
  SAFE.STRPOS(SAFE.LOWER(str), SAFE.LOWER(substr))
);

-- NAME : QUOTE
-- TYPE : STRING
-- DESCRIPTION : Escape the argument for use in an SQL statement.
-- RETURN_TYPE : STRING
-- PARAMETERS : str - The string to quote.
-- DIFFERENCE FROM MYSQL : This UDF uses double-quotes, MySQL uses single-quotes.  (Both ways result
--    in valid SQL literals.)
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.QUOTE(str STRING)
RETURNS STRING
AS (
  SAFE.FORMAT('%T', str)
);

-- NAME : REGEXP_LIKE
-- TYPE : STRING
-- DESCRIPTION : Whether string matches regular expression.  Not in MySQL 5.7.
-- RETURN_TYPE : BOOL
-- PARAMETERS :
--    expr - The input string.
--    pat - The regular expression pattern.
--    match_type (Optional) - The match type.  Defaults to 'i'.  Supports:
--        'i': Case-Insensitive
--        'c': Case-Sensitive
--        'u': Multi-line, lines split by '\n'
--        'un': The '.' character matches newlines
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
--    - 'm' (multiline supporting any Unicode line-separating character) is not supported
--    - Except as listed, different match types can't be combined.
CREATE OR REPLACE FUNCTION mysql.REGEXP_LIKE(expr STRING, pat STRING, match_type STRING DEFAULT 'i')
RETURNS BOOL
AS (
  CASE
    WHEN match_type = 'i' THEN SAFE.REGEXP_CONTAINS(expr, SAFE.CONCAT('(?i)', pat))
    WHEN match_type = 'c' THEN SAFE.REGEXP_CONTAINS(expr, pat)
    WHEN match_type = 'mu' OR match_type = 'um'
      THEN SAFE.REGEXP_CONTAINS(expr, SAFE.CONCAT('(?im)', pat))
    WHEN match_type = 'un' OR match_type = 'nu'
      THEN SAFE.REGEXP_CONTAINS(expr, SAFE.CONCAT('(?is)', pat))
    ELSE ERROR('Unsupported arguments to regexp_like')
    END
);

-- NAME : REGEXP_SUBSTR
-- TYPE : STRING
-- DESCRIPTION: Return substring matching regular expression.  Not in MySQL 5.7.
-- RETURN_TYPE: STRING
-- PARAMETERS:
--  expr: The input string
--  pat: The regular expression
-- DIFFERENCE FROM MYSQL:  This UDF uses Spanner's REGEXP_SUBSTR function, which is based on
--    the re2 library. It may have small differences from MySQL's regexp implementation.
-- LIMITATIONS: Does not support the optional `pos`, `occurrence` and `match_type` arguments that
--    MySQL's REGEXP_SUBSTR supports.
CREATE OR REPLACE FUNCTION mysql.REGEXP_SUBSTR(expr STRING, pat STRING)
RETURNS STRING
AS (
  SAFE.IF(
    expr IS NULL OR pat IS NULL,
    NULL,
    SAFE.IFNULL(SAFE.REGEXP_EXTRACT(expr, SAFE.CONCAT('(?i)', pat)), ''))
);

-- NAME : SPACE
-- TYPE : STRING
-- DESCRIPTION : Return a string of the specified number of spaces.
-- RETURN_TYPE : STRING
-- PARAMETERS : n - The number of spaces to return.
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS : Can only produce up to 1mb of spaces.
CREATE OR REPLACE FUNCTION mysql.SPACE(n INT64)
RETURNS STRING
AS (
  SAFE.IF(n < 0, '', SAFE.REPEAT(' ', n))
);

-- NAME : STRCMP
-- TYPE : STRING
-- DESCRIPTION : Compare two strings.
-- RETURN_TYPE : INT64
-- PARAMETERS :
--   expr1 - The first string.
--   expr2 - The second string.
-- DIFFERENCE FROM MYSQL : MySQL supports both string and binary types.
-- LIMITATIONS : Only supports STRING type.
CREATE OR REPLACE FUNCTION mysql.STRCMP(expr1 STRING, expr2 STRING)
RETURNS INT64
AS (
  CASE
    WHEN expr1 IS NULL OR expr2 IS NULL THEN NULL
    WHEN expr1 < expr2 THEN -1
    WHEN expr1 = expr2 THEN 0
    ELSE 1  -- expr1 > expr2
    END
);

-- NAME : SUBSTRING_INDEX
-- TYPE : STRING
-- DESCRIPTION : Return a substring from a string before the specified number of occurrences of the delimiter. Note that SUBSTRING_INDEX() performs a case-sensitive match when searching for the delimiter.
-- RETURN_TYPE : STRING
-- PARAMETERS :
--    str - The input string.
--    delim - The delimiter string.
--    count - The number of occurrences of the delimiter.
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.SUBSTRING_INDEX(str STRING, delim STRING, count INT64)
RETURNS STRING
AS (
  SAFE.IF(
    delim = '',
    '',
    SAFE.IF(
      count >= 0,
      SAFE.SPLIT_SUBSTR(str, delim, 0, count),
      SAFE.SPLIT_SUBSTR(str, delim, count)))
);

-- NAME : UNHEX
-- TYPE : STRING
-- DESCRIPTION : Return a string containing hex representation of a number.
-- RETURN_TYPE : BYTES
-- PARAMETERS : str - The input string (representing a hexadecimal number).
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.UNHEX(str STRING)
RETURNS BYTES
AS (
  SAFE.FROM_HEX(str)
);

-- NAME : SHA2
-- TYPE : ENCRYPTION AND COMPRESSION
-- DESCRIPTION : Calculate an SHA-2 checksum
-- RETURN_TYPE : STRING
-- PARAMETERS :
--   str - The input bytes.
--   hash_length - the length of the hash (256 or 512)
-- DIFFERENCE FROM MYSQL : MySQL also supports SHA-224 and SHA-384 which Spanner doesn’t. This
--    implementation returns the hex-encoded string, MySQL returns binary data.
-- LIMITATIONS : Supports only hash lengths of 256 and 512. Returns hex string, not binary.
CREATE OR REPLACE FUNCTION mysql.SHA2(str BYTES, hash_length INT64)
RETURNS STRING
AS (
  SAFE.TO_HEX(
    CASE
      WHEN hash_length = 256 THEN SAFE.SHA256(str)
      WHEN hash_length = 512 THEN SAFE.SHA512(str)
      WHEN hash_length IS NULL THEN SAFE.SHA256(str)
      ELSE ERROR(SAFE.FORMAT('hash_length of %d is not supported', hash_length))
      END)
);

-- NAME : JSON_QUOTE
-- TYPE : JSON
-- DESCRIPTION : Quote JSON document
-- RETURN_TYPE : STRING
-- PARAMETERS : expr - The input string
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.JSON_QUOTE(expr STRING)
RETURNS STRING
AS (
  SAFE.IF(expr IS NULL, NULL, SAFE.TO_JSON_STRING(SAFE.TO_JSON(expr)))
);

-- NAME : JSON_UNQUOTE
-- TYPE : JSON
-- DESCRIPTION : Unquote JSON value
-- RETURN_TYPE : STRING
-- PARAMETERS : expr - The input string.
-- DIFFERENCE FROM MYSQL:
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.JSON_UNQUOTE(expr STRING)
RETURNS STRING
AS (
  SAFE.JSON_VALUE(expr)
);

-- NAME : BIN_TO_UUID
-- TYPE : MISCELLANEOUS
-- DESCRIPTION: Convert binary UUID to string
-- RETURN_TYPE: STRING
-- PARAMETERS: binary_uuid: The binary representation of the UUID.
-- DIFFERENCE FROM MYSQL: BIN_TO_UUID() has a two argument version that can be used to swap the
--    time-low and time-high parts of the uuid (note that MySQL uses UUID version 1 from RFC 4122)
--    whereas this UDF uses UUID version version 4 (using random-number generation).
-- LIMITATIONS: Does not support the two-argument version for swapping time parts.
CREATE OR REPLACE FUNCTION mysql.BIN_TO_UUID(binary_uuid BYTES)
RETURNS STRING
AS (
  SAFE.IF(
    SAFE.LENGTH(binary_uuid) != 16,
    ERROR("Incorrect string value"),
    WITH(
      h AS TO_HEX(binary_uuid),
      -- Converts the binary UUID to a hexadecimal string, extracts the five parts
      -- of the UUID using SUBSTR, and concatenates them with hyphens.
      SAFE.CONCAT(
        SAFE.SUBSTR(h, 1, 8),
        '-',
        SAFE.SUBSTR(h, 9, 4),
        '-',
        SAFE.SUBSTR(h, 13, 4),
        '-',
        SAFE.SUBSTR(h, 17, 4),
        '-',
        SAFE.SUBSTR(h, 21, 12))))
);

-- NAME : INET_ATON
-- TYPE : MISCELLANEOUS
-- DESCRIPTION : Return the numeric value of an IP address
-- RETURN_TYPE : INT64
-- PARAMETERS: expr - The string representation of the IP address.
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS : Parses IP addresses more strictly than MySQL.
CREATE OR REPLACE FUNCTION mysql.INET_ATON(expr STRING)
RETURNS INT64
AS (
  SAFE.NET.IPV4_TO_INT64(SAFE.NET.IP_FROM_STRING(expr))
);

-- NAME : INET_NTOA
-- TYPE : MISCELLANEOUS
-- DESCRIPTION : Return the IP address from a numeric value
-- RETURN_TYPE : STRING
-- PARAMETERS:  expr - The integer representation of the IP address.
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS:
CREATE OR REPLACE FUNCTION mysql.INET_NTOA(expr INT64)
RETURNS STRING
AS (
  SAFE.IF(expr < 0 OR expr >= 4294967296, NULL, NET.IP_TO_STRING(NET.IPV4_FROM_INT64(expr)))
);

-- NAME : INET6_ATON
-- TYPE : MISCELLANEOUS
-- DESCRIPTION : Return the numeric value of an IPv6 address
-- RETURN_TYPE : BYTES
-- PARAMETERS : expr - The string representation of the IPv6 address.
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.INET6_ATON(expr STRING)
RETURNS BYTES
AS (
  NET.IP_FROM_STRING(expr)
);

-- NAME : INET6_NTOA
-- TYPE : MISCELLANEOUS
-- DESCRIPTION : Return the IPv6 address from a numeric value
-- RETURN_TYPE : STRING
-- PARAMETERS: expr - The bytes representation of the IPv6 address
-- DIFFERENCE FROM MYSQL:
-- LIMITATIONS:
CREATE OR REPLACE FUNCTION mysql.INET6_NTOA(expr BYTES)
RETURNS STRING
AS (
  NET.IP_TO_STRING(expr)
);

-- NAME : IS_IPV4
-- TYPE : MISCELLANEOUS
-- DESCRIPTION : Whether argument is an IPv4 address
-- RETURN_TYPE : BOOL
-- PARAMETERS : expr - The string to check.
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.IS_IPV4(expr STRING)
RETURNS BOOL
AS (
  SAFE.IFNULL(LENGTH(NET.SAFE_IP_FROM_STRING(expr)), 0) = 4
);

-- NAME : IS_IPV4_COMPAT
-- TYPE : MISCELLANEOUS
-- DESCRIPTION : Whether argument is an IPv4-compatible address
-- RETURN_TYPE : BOOL
-- PARAMETERS: expr - The string to check.
-- DIFFERENCE FROM MYSQL: On a NULL input, MySQL 5.7 returns 0; MySQL 8.0 returns NULL.  This
--     function returns FALSE.
-- LIMITATIONS:
CREATE OR REPLACE FUNCTION mysql.IS_IPV4_COMPAT(expr STRING)
RETURNS BOOL
AS (
  SAFE.IFNULL(
    SAFE.TO_HEX(SAFE.SUBSTR(SAFE.NET.IP_FROM_STRING(expr), 0, 12)) = '000000000000000000000000',
    FALSE)
);

-- NAME : IS_IPV4_MAPPED
-- TYPE : MISCELLANEOUS
-- DESCRIPTION: Whether argument is an IPv4-mapped address
-- RETURN_TYPE: BOOL
-- PARAMETERS: expr - The string to check.
-- DIFFERENCE FROM MYSQL:
-- LIMITATIONS:
CREATE OR REPLACE FUNCTION mysql.IS_IPV4_MAPPED(expr STRING)
RETURNS BOOL
AS (
  SAFE.IFNULL(
    SAFE.TO_HEX(SAFE.SUBSTR(SAFE.NET.IP_FROM_STRING(expr), 0, 12)) = '00000000000000000000ffff',
    FALSE)
);

-- NAME : IS_IPV6
-- TYPE : MISCELLANEOUS
-- DESCRIPTION : Whether argument is an IPv6 address
-- RETURN_TYPE : BOOL
-- PARAMETERS : expr - The string to check.
-- DIFFERENCE FROM MYSQL :
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.IS_IPV6(expr STRING)
RETURNS BOOL
AS (
  SAFE.IFNULL(SAFE.LENGTH(SAFE.NET.IP_FROM_STRING(expr)), 0) = 16
);

-- NAME : IS_UUID
-- TYPE : MISCELLANEOUS
-- DESCRIPTION: Whether argument is a valid UUID. Not in MySQL 5.7.
-- RETURN_TYPE: BOOL
-- PARAMETERS: expr - The string to check.
-- DIFFERENCE FROM MYSQL:
-- LIMITATIONS:
CREATE OR REPLACE FUNCTION mysql.IS_UUID(expr STRING)
RETURNS BOOL
AS (
  -- Uses the REGEXP_CONTAINS function to check if the input string matches the pattern for a valid
  -- UUID.
  SAFE.REGEXP_CONTAINS(
    expr, r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
);

-- NAME : UUID
-- TYPE : MISCELLANEOUS
-- DESCRIPTION : Return a Universal Unique Identifier (UUID)
-- RETURN_TYPE : STRING
-- PARAMETERS :
-- DIFFERENCE FROM MYSQL : Both comply with RFC 4122, but MySQL uses UUID version 1 (using clock
--    and mac address), whereas this UDF uses UUID version 4 (using random-number generation).
-- LIMITATIONS :
CREATE OR REPLACE FUNCTION mysql.UUID()
RETURNS STRING
AS (
  SAFE.GENERATE_UUID()
);

-- NAME : UUID_TO_BIN
-- TYPE : MISCELLANEOUS
-- DESCRIPTION : Convert string UUID to binary
-- RETURN_TYPE : BYTES
-- PARAMETERS : expr - The string representation of the UUID.
-- DIFFERENCE FROM MYSQL : UUID_TO_BIN in MySQL has an optional second argument to swap the
--    time_low and time_high parts for version 1 UUIDs. This UDF doesn't support the
--    optional argument.
-- LIMITATIONS : Does not support the optional second argument for swapping time parts.
CREATE OR REPLACE FUNCTION mysql.UUID_TO_BIN(expr STRING)
RETURNS BYTES
AS (
  SAFE.IF(
    SAFE.REGEXP_CONTAINS(
      expr, r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'),
    SAFE.FROM_HEX(SAFE.REPLACE(expr, '-', '')),
    ERROR(
      SAFE.CONCAT(
        'Incorrect string value: \'',
        SAFE.IFNULL(expr, 'NULL'),
        '\' for function uuid_to_bin')))
);