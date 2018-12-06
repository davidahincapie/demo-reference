DROP TABLE BEAR; 
--SCRIPTS OFTEN BEGIN WITH DROP STATEMENTS TO AVOID NAMING CLASHES

--TABLE CREATION WITH PRIMARY KEYS

CREATE TABLE BEAR (
    BEAR_ID INTEGER PRIMARY KEY,
    BEAR_NAME VARCHAR2(100),
    BIRTHDATE DATE,
    WEIGHT NUMBER(6,2) DEFAULT 200.00,
    BEAR_TYPE_ID INTEGER NOT NULL, --WILL BE A NON-NULLABLE FK
    CAVE_ID INTEGER --WILL BE A NULLABLE FK
);
/
CREATE TABLE BEAR_TYPE (
    BEAR_TYPE_ID INTEGER PRIMARY KEY,
    BEAR_TYPE_NAME VARCHAR2(100)
);
/
CREATE TABLE CAVE (
    CAVE_ID INTEGER PRIMARY KEY,
    CAVE_NAME VARCHAR2(100),
    MAX_BEARS INTEGER DEFAULT 4
);
/
CREATE TABLE BEEHIVE (
    BEEHIVE_ID INTEGER PRIMARY KEY,
    LBS_HONEY NUMBER(5,2) DEFAULT 75.00
);
/
CREATE TABLE BEAR_BEEHIVE (
    BEAR_ID INTEGER,
    BEEHIVE_ID INTEGER,
    PRIMARY KEY (BEAR_ID, BEEHIVE_ID)
);
/

--FOREIGN KEY CONSTRAINTS

--CONSTRAINT: RULE PLACED ON THE CONTENTS OF A TABLE, LIMITS WHAT 
--MAY BE INSERTED IN A COLUMN
--TYPES OF CONSTRAINTS: PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, NOT NULL

ALTER TABLE BEAR 
ADD CONSTRAINT FK_BEAR_BEAR_TYPE
FOREIGN KEY (BEAR_TYPE_ID) REFERENCES BEAR_TYPE(BEAR_TYPE_ID);
/

ALTER TABLE BEAR 
ADD CONSTRAINT FK_BEAR_CAVE
FOREIGN KEY (CAVE_ID) REFERENCES CAVE(CAVE_ID);
/

ALTER TABLE BEAR_BEEHIVE 
ADD CONSTRAINT FK_BEAR_BEAR_BEEHIVE
FOREIGN KEY (BEAR_ID) REFERENCES BEAR(BEAR_ID);
/

ALTER TABLE BEAR_BEEHIVE 
ADD CONSTRAINT FK_BEEHIVE_BEAR_BEEHIVE
FOREIGN KEY (BEEHIVE_ID) REFERENCES BEEHIVE(BEEHIVE_ID);
/

--ADD SOME DATA
--TWO DIFFERENT WAYS TO INSERT: BY FILLING ALL COLUMNS OR SPECIFYING WHICH COLUMNS TO FILL
INSERT INTO BEAR_TYPE VALUES (1, 'Grizzly');
INSERT INTO BEAR_TYPE (BEAR_TYPE_ID, BEAR_TYPE_NAME) VALUES (2, 'Polar');

INSERT ALL 
INTO CAVE
VALUES(1, 'AWESOMECAVE1', 9)
INTO CAVE(CAVE_ID, CAVE_NAME)
VALUES(2, 'Tampa')
SELECT * FROM DUAL; --DUAL IS A DUMMY TABLE 

INSERT ALL 
INTO BEAR(BEAR_ID, BEAR_NAME, BIRTHDATE, BEAR_TYPE_ID, CAVE_ID)
VALUES(72, 'Barry', TO_DATE('1987-08-18 00:00:00','yyyy-mm-dd hh24:mi:ss'),1,2)
INTO BEAR(BEAR_ID, BEAR_NAME, BIRTHDATE, BEAR_TYPE_ID, CAVE_ID)
VALUES(891, 'Tim', TO_DATE('1902-08-18 00:00:00','yyyy-mm-dd hh24:mi:ss'),1,1)
INTO BEAR
VALUES(12, 'Walter', TO_DATE('1901-12-05 00:00:00','yyyy-mm-dd hh24:mi:ss'), 800.00,1,2)
INTO BEAR
VALUES(53, 'Brother', TO_DATE('1995-11-11 13:09:00','yyyy-mm-dd hh24:mi:ss'),100,2,2)
SELECT * FROM DUAL;

--WON'T WORK, DUPLICATE PK
--INSERT INTO BEAR VALUES(53, 'Brother', TO_DATE('1995-11-11 13:09:00','yyyy-mm-dd hh24:mi:ss'),100,2,2)
--WON'T WORK, INVALID FOREIGN KEY 
--INSERT INTO BEAR VALUES(54, 'Brother', TO_DATE('1995-11-11 13:09:00','yyyy-mm-dd hh24:mi:ss'),100,3,2);

INSERT ALL 
INTO BEEHIVE 
VALUES (1,30)
INTO BEEHIVE (BEEHIVE_ID)
VALUES (2)
INTO BEAR_BEEHIVE
VALUES (891, 1)
INTO BEAR_BEEHIVE
VALUES (891, 2)
INTO BEAR_BEEHIVE
VALUES (12, 2)
SELECT * FROM DUAL;

--SELECT STATEMENTS!

SELECT * FROM BEAR;

SELECT BEAR_NAME, BIRTHDATE, WEIGHT FROM BEAR;

SELECT BEAR_NAME, BIRTHDATE, WEIGHT
FROM BEAR
WHERE CAVE_ID = 2;

SELECT CAVE_ID FROM BEAR
GROUP BY CAVE_ID; --JUST THE DISTINCT CAVE_ID VALUES

--AGGREGATE FUNCTION! 
SELECT CAVE_ID, AVG(WEIGHT) FROM BEAR
GROUP BY CAVE_ID; 

SELECT CAVE_ID, ROUND(AVG(WEIGHT),2) FROM BEAR
GROUP BY CAVE_ID
HAVING AVG(WEIGHT) > 300;

--CREATE SEQUENCES AND TRIGGERS TO PROVIDE PK VALUES 

CREATE SEQUENCE SQ_BEAR_PK
START WITH 1000
INCREMENT BY 1;
/
CREATE SEQUENCE SQ_BEAR_TYPE_PK
START WITH 1000
INCREMENT BY 1;
/
CREATE SEQUENCE SQ_CAVE_PK
START WITH 1000
INCREMENT BY 1;
/
CREATE SEQUENCE SQ_BEEHIVE_PK
START WITH 1000
INCREMENT BY 1;
/

CREATE OR REPLACE TRIGGER TR_INSERT_BEAR
BEFORE INSERT ON BEAR --SPECIFY WHICH DML OPERATION, BEOFRE/AFTER, AND WHICH TABLE
FOR EACH ROW
BEGIN
    SELECT SQ_BEAR_PK.NEXTVAL INTO :NEW.BEAR_ID FROM DUAL;
END;
/
CREATE OR REPLACE TRIGGER TR_INSERT_BEAR_TYPE
BEFORE INSERT ON BEAR_TYPE --SPECIFY WHICH DML OPERATION, BEOFRE/AFTER, AND WHICH TABLE
FOR EACH ROW
BEGIN
    SELECT SQ_BEAR_TYPE_PK.NEXTVAL INTO :NEW.BEAR_TYPE_ID FROM DUAL;
END;
/
CREATE OR REPLACE TRIGGER TR_INSERT_BEEHIVE
BEFORE INSERT ON BEEHIVE --SPECIFY WHICH DML OPERATION, BEOFRE/AFTER, AND WHICH TABLE
FOR EACH ROW
BEGIN
    SELECT SQ_BEEHIVE_PK.NEXTVAL INTO :NEW.BEEHIVE_ID FROM DUAL;
END;
/
CREATE OR REPLACE TRIGGER TR_INSERT_CAVE
BEFORE INSERT ON CAVE --SPECIFY WHICH DML OPERATION, BEOFRE/AFTER, AND WHICH TABLE
FOR EACH ROW
BEGIN
    SELECT SQ_CAVE_PK.NEXTVAL INTO :NEW.CAVE_ID FROM DUAL;
END;

--TRY IT OUT! 

INSERT INTO BEAR(BEAR_NAME, BIRTHDATE, BEAR_TYPE_ID, WEIGHT)
VALUES('Bruce', TO_DATE('1999-04-04 00:00:00','yyyy-mm-dd hh24:mi:ss'),2,150);
INSERT INTO BEAR(BEAR_NAME, BIRTHDATE, BEAR_TYPE_ID, WEIGHT)
VALUES('Betty', TO_DATE('1999-04-04 00:00:00','yyyy-mm-dd hh24:mi:ss'),2,900);

--GIVE BRUCE AND BETTY SOMEWHERE TO LIVE
UPDATE BEAR SET CAVE_ID  = 1 
WHERE BIRTHDATE = '04-APR-99';

--JOINS!

--ADD A CAVELESS BEAR
INSERT INTO BEAR(BEAR_NAME, BIRTHDATE, BEAR_TYPE_ID)
VALUES('Winifred', TO_DATE('1999-03-04 00:00:00','yyyy-mm-dd hh24:mi:ss'),2);

INSERT INTO CAVE(CAVE_NAME)
VALUES('Philadelphia');

--SHOW CAVE DETAILS FOR EACH BEAR
SELECT * 
FROM BEAR B --ALIAS BEAR TABLE
LEFT JOIN CAVE ON B.CAVE_ID = CAVE.CAVE_ID; --NO Philadelphia

SELECT * 
FROM BEAR B --ALIAS BEAR TABLE
RIGHT JOIN CAVE ON B.CAVE_ID = CAVE.CAVE_ID; --NO Winifred

SELECT * 
FROM BEAR B --ALIAS BEAR TABLE
FULL JOIN CAVE ON B.CAVE_ID = CAVE.CAVE_ID;

--FILTER OUT COLUMNS, ALIAS COLUMN NAMES IN RESULT SET
SELECT B.BEAR_NAME, B.BIRTHDATE AS BEARTHDATE, CAVE.CAVE_NAME
FROM BEAR B --ALIAS BEAR TABLE
LEFT JOIN CAVE ON B.CAVE_ID = CAVE.CAVE_ID;

--DISPLAY CAVES IN WHICH AVG AGE OF BEARS IS > 20
--JOIN, GROUP BY, HAVING...

