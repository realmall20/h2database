-- Copyright 2004-2020 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--
CREATE TABLE PARENT(ID INT, NAME VARCHAR, PRIMARY KEY(ID) );
> ok

MERGE INTO PARENT AS P
    USING (SELECT X AS ID, 'Coco'||X AS NAME FROM SYSTEM_RANGE(1,2) ) AS S
    ON (P.ID = S.ID AND 1=1 AND S.ID = P.ID)
    WHEN MATCHED THEN
        UPDATE SET P.NAME = S.NAME WHERE 2 = 2;
> exception SYNTAX_ERROR_1

SET MODE Oracle;
> ok

MERGE INTO PARENT AS P
    USING (SELECT X AS ID, 'Coco'||X AS NAME FROM SYSTEM_RANGE(1,2) ) AS S
    ON (P.ID = S.ID AND 1=1 AND S.ID = P.ID)
    WHEN MATCHED THEN
        UPDATE SET P.NAME = S.NAME WHERE 2 = 2
    WHEN NOT MATCHED THEN
        INSERT (ID, NAME) VALUES (S.ID, S.NAME);
> update count: 2

SELECT * FROM PARENT;
> ID NAME
> -- -----
> 1  Coco1
> 2  Coco2
> rows: 2

EXPLAIN PLAN
    MERGE INTO PARENT AS P
        USING (SELECT X AS ID, 'Coco'||X AS NAME FROM SYSTEM_RANGE(1,2) ) AS S
        ON (P.ID = S.ID AND 1=1 AND S.ID = P.ID)
        WHEN MATCHED THEN
            UPDATE SET P.NAME = S.NAME WHERE 2 = 2
        WHEN NOT MATCHED THEN
            INSERT (ID, NAME) VALUES (S.ID, S.NAME);
>> MERGE INTO "PUBLIC"."PARENT" "P" /* PUBLIC.PRIMARY_KEY_8: ID = S.ID AND ID = S.ID */ USING ( SELECT "X" AS "ID", CONCAT('Coco', "X") AS "NAME" FROM SYSTEM_RANGE(1, 2) ) "S" /* SELECT X AS ID, CONCAT('Coco', X) AS NAME FROM SYSTEM_RANGE(1, 2) /* range index */ */ WHEN MATCHED THEN UPDATE SET "NAME" = "S"."NAME" WHEN NOT MATCHED THEN INSERT ("ID", "NAME") VALUES ("S"."ID", "S"."NAME")

SET MODE Regular;
> ok

DROP TABLE PARENT;
> ok

CREATE SCHEMA SOURCESCHEMA;
> ok

CREATE TABLE SOURCESCHEMA.SOURCE(ID INT PRIMARY KEY, "VALUE" INT);
> ok

INSERT INTO SOURCESCHEMA.SOURCE VALUES (1, 10), (3, 30), (5, 50);
> update count: 3

CREATE SCHEMA DESTSCHEMA;
> ok

CREATE TABLE DESTSCHEMA.DESTINATION(ID INT PRIMARY KEY, "VALUE" INT);
> ok

INSERT INTO DESTSCHEMA.DESTINATION VALUES (3, 300), (6, 600);
> update count: 2

MERGE INTO DESTSCHEMA.DESTINATION USING SOURCESCHEMA.SOURCE ON (DESTSCHEMA.DESTINATION.ID = SOURCESCHEMA.SOURCE.ID)
    WHEN MATCHED THEN UPDATE SET "VALUE" = SOURCESCHEMA.SOURCE."VALUE"
    WHEN NOT MATCHED THEN INSERT (ID, "VALUE") VALUES (SOURCESCHEMA.SOURCE.ID, SOURCESCHEMA.SOURCE."VALUE");
> update count: 3

SELECT * FROM DESTSCHEMA.DESTINATION;
> ID VALUE
> -- -----
> 1  10
> 3  30
> 5  50
> 6  600
> rows: 4

DROP SCHEMA SOURCESCHEMA CASCADE;
> ok

DROP SCHEMA DESTSCHEMA CASCADE;
> ok

CREATE TABLE SOURCE_TABLE(ID BIGINT PRIMARY KEY, C1 INT NOT NULL);
> ok

INSERT INTO SOURCE_TABLE VALUES (1, 10), (2, 20), (3, 30);
> update count: 3

CREATE TABLE DEST_TABLE(ID BIGINT PRIMARY KEY, C1 INT NOT NULL, C2 INT NOT NULL);
> ok

INSERT INTO DEST_TABLE VALUES (2, 200, 2000), (4, 400, 4000);
> update count: 2

MERGE INTO DEST_TABLE USING SOURCE_TABLE ON (DEST_TABLE.ID = SOURCE_TABLE.ID)
    WHEN MATCHED THEN UPDATE SET DEST_TABLE.C1 = SOURCE_TABLE.C1, DEST_TABLE.C2 = 100;
> update count: 1

SELECT * FROM DEST_TABLE;
> ID C1  C2
> -- --- ----
> 2  20  100
> 4  400 4000
> rows: 2

MERGE INTO DEST_TABLE D USING SOURCE_TABLE S ON (D.ID = S.ID)
    WHEN MATCHED THEN UPDATE SET D.C1 = S.C1, D.C2 = 100
    WHEN NOT MATCHED THEN INSERT (ID, C1, C2) VALUES (S.ID, S.C1, 1000);
> update count: 3

SELECT * FROM DEST_TABLE;
> ID C1  C2
> -- --- ----
> 1  10  1000
> 2  20  100
> 3  30  1000
> 4  400 4000
> rows: 4

DROP TABLE SOURCE_TABLE;
> ok

DROP TABLE DEST_TABLE;
> ok

CREATE TABLE TEST(C1 INT, C2 INT, C3 INT);
> ok

MERGE INTO TEST USING DUAL ON C1 = 11 AND C2 = 21
    WHEN NOT MATCHED THEN INSERT (C1, C2, C3) VALUES (11, 21, 31)
    WHEN MATCHED THEN UPDATE SET C3 = 31;
> update count: 1

MERGE INTO TEST USING DUAL ON (C1 = 11 AND C2 = 22)
    WHEN NOT MATCHED THEN INSERT (C1, C2, C3) VALUES (11, 22, 32)
    WHEN MATCHED THEN UPDATE SET C3 = 32;
> update count: 1

SELECT * FROM TEST ORDER BY C1, C2;
> C1 C2 C3
> -- -- --
> 11 21 31
> 11 22 32
> rows (ordered): 2

MERGE INTO TEST USING DUAL ON C1 = 11 AND C2 = 21
    WHEN NOT MATCHED THEN INSERT (C1, C2, C3) VALUES (11, 21, 33)
    WHEN MATCHED THEN UPDATE SET C3 = 33;
> update count: 1

SELECT * FROM TEST ORDER BY C1, C2;
> C1 C2 C3
> -- -- --
> 11 21 33
> 11 22 32
> rows (ordered): 2

MERGE INTO TEST USING (SELECT 1 FROM DUAL) ON (C1 = 11 AND C2 = 21)
    WHEN NOT MATCHED THEN INSERT (C1, C2, C3) VALUES (11, 21, 33)
    WHEN MATCHED THEN UPDATE SET C3 = 34;
> update count: 1

SELECT * FROM TEST ORDER BY C1, C2;
> C1 C2 C3
> -- -- --
> 11 21 34
> 11 22 32
> rows (ordered): 2

DROP TABLE TEST;
> ok

CREATE TABLE TEST (ID INT, "VALUE" INT);
> ok

MERGE INTO TEST USING DUAL ON (ID = 1)
    WHEN MATCHED THEN UPDATE SET "VALUE" = 1
    WHEN;
> exception SYNTAX_ERROR_2

MERGE INTO TEST USING DUAL ON (ID = 1)
    WHEN MATCHED THEN UPDATE SET "VALUE" = 1
    WHEN NOT MATCHED THEN;
> exception SYNTAX_ERROR_2

MERGE INTO TEST USING DUAL ON (ID = 1)
    WHEN NOT MATCHED THEN INSERT (ID, "VALUE") VALUES (1, 1)
    WHEN;
> exception SYNTAX_ERROR_2

MERGE INTO TEST USING DUAL ON (ID = 1)
    WHEN NOT MATCHED THEN INSERT (ID, "VALUE") VALUES (1, 1)
    WHEN MATCHED THEN;
> exception SYNTAX_ERROR_2

DROP TABLE TEST;
> ok

CREATE TABLE TEST(ID INT PRIMARY KEY);
> ok

MERGE INTO TEST USING (SELECT CAST(? AS INT) ID FROM DUAL) S ON (TEST.ID = S.ID)
    WHEN NOT MATCHED THEN INSERT (ID) VALUES (S.ID);
{
10
20
30
};
> update count: 3

SELECT * FROM TEST;
> ID
> --
> 10
> 20
> 30
> rows: 3

MERGE INTO TEST USING (SELECT 40) ON UNKNOWN_COLUMN = 1 WHEN NOT MATCHED THEN INSERT (ID) VALUES (40);
> exception COLUMN_NOT_FOUND_1

DROP TABLE TEST;
> ok

CREATE TABLE TEST(ID INT PRIMARY KEY, "VALUE" INT);
> ok

INSERT INTO TEST VALUES (1, 10), (2, 20);
> update count: 2

MERGE INTO TEST USING (SELECT 1) ON (ID < 0)
    WHEN MATCHED THEN UPDATE SET "VALUE" = 30
    WHEN NOT MATCHED THEN INSERT VALUES (3, 30);
> update count: 1

SELECT * FROM TEST;
> ID VALUE
> -- -----
> 1  10
> 2  20
> 3  30
> rows: 3

MERGE INTO TEST USING (SELECT 1) ON (ID = ID)
    WHEN MATCHED THEN UPDATE SET "VALUE" = 40
    WHEN NOT MATCHED THEN INSERT VALUES (4, 40);
> update count: 3

SELECT * FROM TEST;
> ID VALUE
> -- -----
> 1  40
> 2  40
> 3  40
> rows: 3

MERGE INTO TEST USING (SELECT 1) ON (1 = 1)
    WHEN MATCHED THEN UPDATE SET "VALUE" = 50
    WHEN NOT MATCHED THEN INSERT VALUES (5, 50);
> update count: 3

SELECT * FROM TEST;
> ID VALUE
> -- -----
> 1  50
> 2  50
> 3  50
> rows: 3

MERGE INTO TEST USING (SELECT 1) ON 1 = 1
    WHEN MATCHED THEN UPDATE SET "VALUE" = 60 WHERE ID = 3 DELETE WHERE ID = 2;
> exception SYNTAX_ERROR_1

MERGE INTO TEST USING (SELECT 1 A) ON 1 = 1
    WHEN MATCHED THEN DELETE WHERE ID = 2;
> exception SYNTAX_ERROR_1

SET MODE Oracle;
> ok

MERGE INTO TEST USING (SELECT 1 A) ON 1 = 1
    WHEN MATCHED THEN DELETE WHERE ID = 2;
> update count: 1

SET MODE Regular;
> ok

SELECT * FROM TEST;
> ID VALUE
> -- -----
> 1  50
> 3  50
> rows: 2

DROP TABLE TEST;
> ok

CREATE TABLE T(ID INT, F BOOLEAN, "VALUE" INT);
> ok

INSERT INTO T VALUES (1, FALSE, 10), (2, TRUE, 20);
> update count: 2

CREATE TABLE S(S_ID INT, S_F BOOLEAN, S_VALUE INT);
> ok

INSERT INTO S VALUES (1, FALSE, 100), (2, TRUE, 200), (3, FALSE, 300), (4, TRUE, 400);
> update count: 4

MERGE INTO T USING S ON ID = S_ID
    WHEN MATCHED AND F THEN UPDATE SET "VALUE" = S_VALUE
    WHEN MATCHED AND NOT F THEN DELETE
    WHEN NOT MATCHED AND S_F THEN INSERT VALUES (S_ID, S_F, S_VALUE);
> update count: 3

SELECT * FROM T;
> ID F    VALUE
> -- ---- -----
> 2  TRUE 200
> 4  TRUE 400
> rows: 2

DROP TABLE T, S;
> ok

CREATE TABLE T(ID INT, A INT, B INT) AS VALUES (1, 1, 1), (2, 1, 2);
> ok

CREATE TABLE S(ID INT, A INT, B INT) AS VALUES (1, 1, 3), (2, 1, 4);
> ok

MERGE INTO T USING S ON T.A = S.A WHEN MATCHED THEN UPDATE SET B = S.B;
> exception DUPLICATE_KEY_1

CREATE TABLE S2(ID INT, A INT, B INT) AS VALUES (3, 3, 3);
> ok

MERGE INTO T USING (SELECT * FROM S UNION SELECT * FROM S2) S ON T.ID = S.ID
    WHEN MATCHED THEN UPDATE SET A = S.A, B = S.B
    WHEN NOT MATCHED THEN INSERT VALUES (S.ID, S.A, S.B);
> update count: 3

TABLE T;
> ID A B
> -- - -
> 1  1 3
> 2  1 4
> 3  3 3
> rows: 3

MERGE INTO T USING (S) ON T.ID = S.ID
    WHEN MATCHED THEN UPDATE SET B = S.B + 1;
> update count: 2

TABLE T;
> ID A B
> -- - -
> 1  1 4
> 2  1 5
> 3  3 3
> rows: 3

DROP TABLE T, S, S2 CASCADE;
> ok

CREATE TABLE TEST(ID INT, V INT);
> ok

MERGE INTO TEST USING VALUES (1, 2) S ON TEST.ID = S.C1 WHEN NOT MATCHED THEN INSERT VALUES (1, 2), (3, 4);
> exception SYNTAX_ERROR_1

CREATE TABLE T(A INT);
> ok

MERGE INTO T USING (SELECT 1 A) S ON (TRUE)
WHEN NOT MATCHED AND S.X THEN INSERT VALUES (1);
> exception COLUMN_NOT_FOUND_1

DROP TABLE T;
> ok

CREATE TABLE A(ID INT, V INT) AS VALUES (1, 1), (2, 2);
> ok

CREATE TABLE B(ID INT, V INT) AS VALUES (2, 4), (3, 6);
> ok

MERGE INTO A USING (SELECT * FROM B) S
    ON A.ID = S.ID
    WHEN MATCHED THEN UPDATE SET V = S.V;
> update count: 1

TABLE A;
> ID V
> -- -
> 1  1
> 2  4
> rows: 2

DROP TABLE A, B;
> ok

CREATE TABLE TARGET(ID INT, V INT);
> ok

MERGE INTO TARGET T USING (VALUES (1, 2)) S(ID, V)
    ON T.ID = S.ID
    WHEN NOT MATCHED THEN INSERT VALUES (S.ID, S.V);
> update count: 1

CREATE TABLE SOURCE(ID INT, V INT) AS VALUES (3, 4);
> ok

MERGE INTO TARGET T USING SOURCE S(ID, V)
    ON T.ID = S.ID
    WHEN NOT MATCHED THEN INSERT VALUES (S.ID, S.V);
> update count: 1

TABLE TARGET;
> ID V
> -- -
> 1  2
> 3  4
> rows: 2

DROP TABLE SOURCE, TARGET;
> ok

CREATE TABLE T(ID INT, V INT) AS VALUES (1, 1), (2, 2);
> ok

MERGE INTO T USING (SELECT 1) ON (TRUE)
    WHEN MATCHED THEN UPDATE SET V = 2
    WHEN MATCHED AND ID = 2 THEN UPDATE SET V = 3;
> update count: 2

TABLE T;
> ID V
> -- -
> 1  2
> 2  2
> rows: 2

TRUNCATE TABLE T;
> ok

INSERT INTO T VALUES (1, 1);
> update count: 1

MERGE INTO T USING (SELECT 1) ON (ID = 1)
    WHEN MATCHED THEN UPDATE SET V = 2
    WHEN MATCHED THEN UPDATE SET V = 3;
> update count: 1

TABLE T;
> ID V
> -- -
> 1  2
> rows: 1

SELECT * FROM FINAL TABLE (MERGE INTO T USING (SELECT 1) ON (ID = 1)
    WHEN MATCHED THEN UPDATE SET V = 4
    WHEN MATCHED THEN UPDATE SET V = 5);
> ID V
> -- -
> 1  4
> rows: 1

EXPLAIN MERGE INTO T USING (VALUES (1, 2)) S(ID, V) ON T.ID = S.ID
    WHEN NOT MATCHED AND T.ID = 1 THEN INSERT VALUES (S.ID, S.V)
    WHEN NOT MATCHED THEN INSERT VALUES (S.ID, S.V + 1)
    WHEN MATCHED AND T.ID = 2 THEN UPDATE SET V = S.ID + 2
    WHEN MATCHED THEN UPDATE SET V = S.ID + 3;
>> MERGE INTO "PUBLIC"."T" /* PUBLIC.T.tableScan */ USING ( VALUES (1, 2) ) "S"("ID", "V") /* VALUES (1, 2) */ WHEN NOT MATCHED AND "T"."ID" = 1 THEN INSERT ("ID", "V") VALUES ("S"."ID", "S"."V") WHEN NOT MATCHED THEN INSERT ("ID", "V") VALUES ("S"."ID", "S"."V" + 1) WHEN MATCHED AND "T"."ID" = 2 THEN UPDATE SET "V" = "S"."ID" + 2 WHEN MATCHED THEN UPDATE SET "V" = "S"."ID" + 3

EXPLAIN MERGE INTO T USING (VALUES (1, 2)) S(ID, V) ON T.ID = S.ID
    WHEN MATCHED AND T.ID = 1 THEN DELETE
    WHEN MATCHED THEN DELETE;
>> MERGE INTO "PUBLIC"."T" /* PUBLIC.T.tableScan */ USING ( VALUES (1, 2) ) "S"("ID", "V") /* VALUES (1, 2) */ WHEN MATCHED AND "T"."ID" = 1 THEN DELETE WHEN MATCHED THEN DELETE

DROP TABLE T;
> ok
