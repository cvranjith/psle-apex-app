

    Schema
    Object Type
    Object Name
    Script

Script
Generated DDL

CREATE TABLE  "SUBJECTS" 
   (	"ID" VARCHAR2(32) COLLATE "USING_NLS_COMP" DEFAULT SYS_GUID(), 
	"SUBJECT" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"CHAPTER" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"THEME" VARCHAR2(4000) COLLATE "USING_NLS_COMP"
   )  DEFAULT COLLATION "USING_NLS_COMP"
/
CREATE TABLE  "TB_USERS" 
   (	"USER_ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"USER_NAME" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"LAST_LOGGED_IN" DATE, 
	"AUTHORIZED" VARCHAR2(1) COLLATE "USING_NLS_COMP"
   )  DEFAULT COLLATION "USING_NLS_COMP"
/
CREATE TABLE  "QUESTIONS" 
   (	"ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"TEST_PAPER_ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"QUESTION_NUMBER" NUMBER, 
	"REMARKS" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"SCREENSHOT" CLOB COLLATE "USING_NLS_COMP", 
	"CHAPTER" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"MARKS_LOST" NUMBER, 
	"SECTION" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"SCREENSHOT_ID" VARCHAR2(200) COLLATE "USING_NLS_COMP"
   )  DEFAULT COLLATION "USING_NLS_COMP"
/
CREATE TABLE  "TEST_PAPERS" 
   (	"ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"TEST_NAME" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"TEST_YEAR" NUMBER, 
	"DATE_TAKEN" DATE, 
	"SCAN_LINK" VARCHAR2(500) COLLATE "USING_NLS_COMP", 
	"MARKS" NUMBER, 
	"REMARKS" VARCHAR2(4000) COLLATE "USING_NLS_COMP", 
	"CREATED_BY" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"CREATED_ON" DATE, 
	"SUBJECT" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"WRONG_QUESTIONS_SCAN" VARCHAR2(4000) COLLATE "USING_NLS_COMP", 
	"SCAN_ID" NUMBER
   )  DEFAULT COLLATION "USING_NLS_COMP"
/
CREATE TABLE  "TB_IMG" 
   (	"ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"IMG" CLOB COLLATE "USING_NLS_COMP", 
	"DT" DATE
   )  DEFAULT COLLATION "USING_NLS_COMP"
/
CREATE TABLE  "TEST_PAPER_SECTIONS" 
   (	"ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"SUBJECT" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"SECTION" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"TOTAL_MARKS" NUMBER, 
	"TOTAL_QUESTIONS" NUMBER
   )  DEFAULT COLLATION "USING_NLS_COMP"
/

Rem No function found to generate DDL.

Rem No index found to generate DDL.

Rem No package found to generate DDL.

CREATE OR REPLACE EDITIONABLE PROCEDURE  "PR_POST_LOGIN" 
is
l_user varchar2(200) := v('APP_USER');
begin
    update tb_USERS set last_logged_in = sysdate where upper(user_id) = upper(l_user);
    if sql%rowcount = 0
    then
        insert into tb_USERS (user_id, user_name, last_logged_in, authorized)
        values
        (l_user,l_user,sysdate,'N');
    end if;
end;
/

Rem No sequence found to generate DDL.

Rem No synonym found to generate DDL.

CREATE OR REPLACE NONEDITIONABLE TRIGGER  "TR_QUESTIONS" 
    before insert or update on wksp_psle.questions
    for each row
begin
    if :new.id is null then
        :new.id := sys_guid();
    end if;
    if :new.screenshot_id is not null
    then
        for i in (select a.rowid rid, img from tb_img a where id = :new.screenshot_id)
        loop
            :new.screenshot := i.img;
            delete tb_img where rowid = i.rid;
        end loop;
    end if;
end;
/
ALTER TRIGGER  "TR_QUESTIONS" ENABLE
/
CREATE OR REPLACE NONEDITIONABLE TRIGGER  "TR_SUBJECTS" 
    before insert or update on wksp_psle.subjects
    for each row
begin
    if :new.id is null then
        :new.id := sys_guid();
    end if;
end;
/
ALTER TRIGGER  "TR_SUBJECTS" ENABLE
/
CREATE OR REPLACE NONEDITIONABLE TRIGGER  "TR_TEST_PAPERS" 
    before insert or update on wksp_psle.test_papers
    for each row
begin
    if :new.id is null then
        :new.id := sys_guid();
    end if;
    if :new.created_by is null then
        :new.created_by := v('APP_USER');
    end if;
    if :new.created_on is null then
        :new.created_on := to_date(to_char(sysdate,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS');
    end if;
end;
/
ALTER TRIGGER  "TR_TEST_PAPERS" ENABLE
/

CREATE OR REPLACE FORCE EDITIONABLE VIEW  "VW_MARKS" ("ID", "SUBJECT", "SECTION", "TOTAL_MARKS", "TOTAL_QUESTIONS", "TEST_PAPER_ID", "T", "MARKS_LOST", "QUESTIONS_RECORDED", "MARKS_SCORED") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select a."ID",a."SUBJECT",a."SECTION",a."TOTAL_MARKS",a."TOTAL_QUESTIONS",a."TEST_PAPER_ID",a."T",a."MARKS_LOST",a."QUESTIONS_RECORDED", total_marks -marks_lost marks_scored
from
(
select a.* , 
b.id test_paper_id,
b.TEST_NAME t,
nvl((select sum(marks_lost) from wksp_psle.questions c where c.test_paper_id = b.id and c.section = a.section and marks_lost > 0),0) marks_lost,
--(select count(1) from wksp_psle.questions c where c.test_paper_id = b.id and c.section = a.section) marks_lost,
(select count(1) from wksp_psle.questions c where c.test_paper_id = b.id and c.section = a.section) questions_recorded
from
 wksp_psle.test_paper_sections a,
 wksp_psle.test_papers b
where a.SUBJECT = b.subject
) a order by section
/
CREATE OR REPLACE FORCE EDITIONABLE VIEW  "VW_QUESTIONS" ("TEST_PAPER_ID", "TEST_NAME", "SUBJECT", "TEST_YEAR", "SECTION", "QUESTION_ID", "QUESTION_NUMBER", "CHAPTER", "THEME", "MARKS_LOST") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select  a.test_paper_id, c.TEST_NAME, c.subject, c.test_year, a.section, a.id question_id,
a.question_number, a.chapter, b.theme ,  1 marks_lost
from wksp_psle.questions a, WKSP_PSLE.SUBJECTS  b, wksp_psle.test_papers c
where a.chapter = b.chapter
and c.id = a.test_paper_id 
and b.subject = c.subject 
order by 1,2,3,4,5,7
/
CREATE OR REPLACE FORCE EDITIONABLE VIEW  "VW_TEST_PAPERS" ("ID", "TEST_NAME", "TEST_YEAR", "DATE_TAKEN", "SCAN_LINK", "MARKS", "REMARKS", "CREATED_BY", "CREATED_ON", "SUBJECT", "WRONG_QUESTIONS_SCAN", "SCAN_ID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select "ID","TEST_NAME","TEST_YEAR","DATE_TAKEN","SCAN_LINK","MARKS","REMARKS","CREATED_BY","CREATED_ON","SUBJECT","WRONG_QUESTIONS_SCAN","SCAN_ID" from test_papers order by scan_id desc
/

Rem No database link found to generate DDL.

Rem No type found to generate DDL.

Rem No materialized view found to generate DDL.

