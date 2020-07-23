-- Copyright 2004-2020 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

CREATE TABLE TEST(B1 BLOB, B2 BINARY LARGE OBJECT, B3 TINYBLOB, B4 MEDIUMBLOB, B5 LONGBLOB, B6 IMAGE);
> ok

SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'TEST' ORDER BY ORDINAL_POSITION;
> COLUMN_NAME DATA_TYPE
> ----------- -------------------
> B1          BINARY LARGE OBJECT
> B2          BINARY LARGE OBJECT
> B3          BINARY LARGE OBJECT
> B4          BINARY LARGE OBJECT
> B5          BINARY LARGE OBJECT
> B6          BINARY LARGE OBJECT
> rows (ordered): 6

DROP TABLE TEST;
> ok

CREATE TABLE TEST(B0 BLOB(10), B1 BLOB(10K), B2 BLOB(10M), B3 BLOB(10G), B4 BLOB(10T), B5 BLOB(10P));
> ok

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'TEST' ORDER BY ORDINAL_POSITION;
> COLUMN_NAME DATA_TYPE           CHARACTER_MAXIMUM_LENGTH
> ----------- ------------------- ------------------------
> B0          BINARY LARGE OBJECT 10
> B1          BINARY LARGE OBJECT 10240
> B2          BINARY LARGE OBJECT 10485760
> B3          BINARY LARGE OBJECT 10737418240
> B4          BINARY LARGE OBJECT 10995116277760
> B5          BINARY LARGE OBJECT 11258999068426240
> rows (ordered): 6

INSERT INTO TEST(B0) VALUES (X'0102030405060708091011');
> exception VALUE_TOO_LONG_2

INSERT INTO TEST(B0) VALUES (X'01020304050607080910');
> update count: 1

SELECT B0 FROM TEST;
>> X'01020304050607080910'

DROP TABLE TEST;
> ok

CREATE TABLE TEST(B BLOB(8192P));
> exception INVALID_VALUE_2

EXPLAIN VALUES CAST(X'00' AS BLOB(1));
>> VALUES (CAST(X'00' AS BLOB(1)))

CREATE TABLE T(C BLOB(0));
> exception INVALID_VALUE_2

CREATE TABLE TEST(C1 BLOB(1K CHARACTERS), C2 BLOB(1K OCTETS));
> exception SYNTAX_ERROR_2
