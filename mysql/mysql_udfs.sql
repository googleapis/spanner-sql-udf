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
