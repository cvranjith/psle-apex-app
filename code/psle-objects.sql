

    Schema
    Object Type
    Object Name
    Script

Script


  CREATE TABLE "QUESTIONS" 
   (	"ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"TEST_PAPER_ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"QUESTION_NUMBER" NUMBER, 
	"REMARKS" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"SCREENSHOT" CLOB COLLATE "USING_NLS_COMP", 
	"CHAPTER" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"MARKS_LOST" NUMBER, 
	"SECTION" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"SCREENSHOT_ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"ANSWER_KEY" VARCHAR2(4000) COLLATE "USING_NLS_COMP", 
	"SECOND_ATTEMPT" VARCHAR2(1) COLLATE "USING_NLS_COMP", 
	"NUMBER_OF_ATTEMPTS" NUMBER DEFAULT 1, 
	"CATEGORY" VARCHAR2(10) COLLATE "USING_NLS_COMP" DEFAULT '-', 
	"MCQ" VARCHAR2(1) COLLATE "USING_NLS_COMP"
   )  DEFAULT COLLATION "USING_NLS_COMP" ;

  CREATE TABLE "TB_EDITED_IMG" 
   (	"QUESTION_ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"IMG_DATA" CLOB COLLATE "USING_NLS_COMP", 
	"TS" TIMESTAMP (6), 
	 PRIMARY KEY ("QUESTION_ID")
  USING INDEX  ENABLE
   )  DEFAULT COLLATION "USING_NLS_COMP" ;

  CREATE TABLE "TB_IMG" 
   (	"ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"IMG" CLOB COLLATE "USING_NLS_COMP", 
	"DT" DATE
   )  DEFAULT COLLATION "USING_NLS_COMP" ;

  CREATE TABLE "TB_QUIZ" 
   (	"QUIZ_ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"SUBJECT" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"THEME" VARCHAR2(32000) COLLATE "USING_NLS_COMP", 
	"CHAPTER" VARCHAR2(32000) COLLATE "USING_NLS_COMP", 
	"TEST_NAME" VARCHAR2(32000) COLLATE "USING_NLS_COMP", 
	"SECTION" VARCHAR2(32000) COLLATE "USING_NLS_COMP", 
	"ATTEMPTS" VARCHAR2(32000) COLLATE "USING_NLS_COMP", 
	"PRELIM_ERROR" VARCHAR2(32000) COLLATE "USING_NLS_COMP", 
	"QUIZ_NAME" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"CREATED_ON" DATE, 
	"PRACTICE_MODE" VARCHAR2(1) COLLATE "USING_NLS_COMP", 
	"MCQ" VARCHAR2(1) COLLATE "USING_NLS_COMP", 
	 PRIMARY KEY ("QUIZ_ID")
  USING INDEX  ENABLE
   )  DEFAULT COLLATION "USING_NLS_COMP" ;

  CREATE TABLE "SUBJECTS" 
   (	"ID" VARCHAR2(32) COLLATE "USING_NLS_COMP" DEFAULT SYS_GUID(), 
	"SUBJECT" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"CHAPTER" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"THEME" VARCHAR2(4000) COLLATE "USING_NLS_COMP"
   )  DEFAULT COLLATION "USING_NLS_COMP" ;

  CREATE TABLE "TB_QUIZ_QUESTIONS" 
   (	"ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"QUIZ_ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"QUESTION_ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"ANSWER" VARCHAR2(2000) COLLATE "USING_NLS_COMP", 
	 PRIMARY KEY ("ID")
  USING INDEX  ENABLE
   )  DEFAULT COLLATION "USING_NLS_COMP" ;

  CREATE TABLE "TB_USERS" 
   (	"USER_ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"USER_NAME" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"LAST_LOGGED_IN" DATE, 
	"AUTHORIZED" VARCHAR2(1) COLLATE "USING_NLS_COMP"
   )  DEFAULT COLLATION "USING_NLS_COMP" ;

  CREATE TABLE "TEST_PAPERS" 
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
   )  DEFAULT COLLATION "USING_NLS_COMP" ;

  CREATE TABLE "TEST_PAPER_SECTIONS" 
   (	"ID" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"SUBJECT" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"SECTION" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"TOTAL_MARKS" NUMBER, 
	"TOTAL_QUESTIONS" NUMBER
   )  DEFAULT COLLATION "USING_NLS_COMP" ;

  CREATE OR REPLACE EDITIONABLE TRIGGER "TR_QUESTIONS" 
    before insert or update on wksp_psle.questions
    for each row
begin
    if :new.id is null then
        :new.id := nvl(:new.screenshot_id,sys_guid());
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
ALTER TRIGGER "TR_QUESTIONS" ENABLE;

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "TR_SUBJECTS" 
    before insert or update on wksp_psle.subjects
    for each row
begin
    if :new.id is null then
        :new.id := sys_guid();
    end if;
end;
/
ALTER TRIGGER "TR_SUBJECTS" ENABLE;

  CREATE OR REPLACE EDITIONABLE TRIGGER "TR_QUIZ" 
    before insert or update on wksp_psle.tb_quiz
    for each row
declare
    n number;
begin
    if :new.quiz_id is null then
        :new.quiz_id := sys_guid();
    end if;
    if :new.created_on is null then
    :new.created_on := sysdate;
    end if;
end;
/
ALTER TRIGGER "TR_QUIZ" ENABLE;

  CREATE INDEX "IND_QUIZ_QUESTION_ID" ON "TB_QUIZ_QUESTIONS" ("QUIZ_ID", "QUESTION_ID") 
  ;

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "TR_TEST_PAPERS" 
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
ALTER TRIGGER "TR_TEST_PAPERS" ENABLE;


























  CREATE INDEX "IND_QUIZ_QUESTION_ID" ON "TB_QUIZ_QUESTIONS" ("QUIZ_ID", "QUESTION_ID") 
  ;

  CREATE UNIQUE INDEX "SYS_C0042379" ON "TB_EDITED_IMG" ("QUESTION_ID") 
  ;

  CREATE UNIQUE INDEX "SYS_C0042491" ON "TB_QUIZ" ("QUIZ_ID") 
  ;

  CREATE UNIQUE INDEX "SYS_C0042492" ON "TB_QUIZ_QUESTIONS" ("ID") 
  ;





























create or replace procedure           collage
(
p_id in varchar2,p_subj in varchar2,p_theme in varchar2,p_chapter in varchar2, p_number_of_attempts in varchar2,
p_test_name in varchar2, p_category in varchar2
)
is
l_num number := 0;
l_max number := 50;
c clob;
b boolean := false;
ans varchar2(32000);
n number :=0;
begin
htp.p('<html>');
htp.p('<style>');
htp.p('
{table
  width: 210mm;
  table-layout: fixed;
  border-collapse: collapse;
}');
htp.p('
  th, td {
    width: auto;
    overflow: hidden;
    word-wrap: break-word;
    border: 1px solid black; 
    border-collapse: collapse;
  }
  tr {
    page-break-inside: avoid;
  }
  .cell-content {
    max-height: 220mm; 
    overflow: hidden;
  }
 .row-num {
    display: inline-block;
    width: 24px; /* Adjust the circle size as needed */
    height: 24px; /* Adjust the circle size as needed */
    border-radius: 50%;
    background-color: black;
    color: white;
    text-align: center;
    font-weight: bold;
    margin-right: 8px; /* Add spacing between the circle and text */
    line-height: 24px; /* Center the text vertically inside the circle */
  }
  p {page-break-after: always;}
}
</style>
<table width="100%">');
for i in 
    (
    select  *
    from    vw_questions
    where   (p_id       is null or (p_id      is not null and     test_paper_id     =          p_id))
    and     (p_subj     is null or (p_subj    is not null and ':'||p_subj||':'      like '%:'||subject||':%'))
    and     (p_theme    is null or (p_theme   is not null and ':'||p_theme||':'     like '%:'||theme||':%'))
    and     (p_chapter  is null or (p_chapter is not null and ':'||p_chapter||':'   like '%:'||chapter||':%'))
    and     (p_test_name  is null or (p_test_name is not null and ':'||p_test_name||':'   like '%:'||test_name||':%'))
    and     (p_number_of_attempts  is null or (p_number_of_attempts is not null and ':'||p_number_of_attempts||':'   like '%:'||number_of_attempts||':%'))
    and     (p_category  is null or (p_category is not null and ':'||p_category||':'   like '%:'||category||':%'))
    order by scan_id, section, question_id
    )
loop
    n := n+1;
    ans := ans||chr(10)||
    
    '<tr><td>' || n|| ' </td><td> [' || i.scan_id || '/'|| i.question_number ||']'|| '</td><td> &nbsp;'|| i.answer_key ||' &nbsp; </td></tr>';

    htp.p('<tr><td> <div class="cell-content"> <div class="row-num">'|| n|| '</div> [' || i.scan_id || '/'|| i.question_number ||'] #'||i.section|| ' [' || i.test_name || '] ' /*|| i.answer_key*/ || '</br><br><br> <img width="100%" src="');
    b := false;
    c := null;
    for j in (select img_data from tb_edited_img where question_id = i.question_id)
    loop
        c := j.img_data;
        b := true;
        exit;
    end loop;
    if not b then
    for j in (select screenshot from questions where id = i.question_id) loop
        c := j.screenshot;
        b := true;
        --htpprn(j.screenshot);
    end loop;
    end if;
    if b then
    htpprn(c);
    end if;
    htp.p('"/><br><br><br><br><br><br></div></td></tr>');
    l_num := l_num+1;
    if l_num > l_max then
        exit;
    end if;
end loop;
htp.p('</table>');
if l_num > l_max then htp.p('Maximum of ' || l_max || ' questions reached'); end if;

htp.p('<p><br><br><br> <pre> Answer Keys <br><table>' || ans||'</table></pre>');
htp.p('</html>');
end;
/
create or replace procedure collage1(p_id in varchar2,p_subj in varchar2,p_theme in varchar2,p_chapter in varchar2)
is
l_num number := 0;
l_max number := 50;
begin
htp.p('<html>'); --<style>table, th, td {  border: 1px solid black;  border-collapse: collapse;}</style>
htp.p('
<head>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.3.4/jspdf.debug.js">
</script>
<script>
function generatePDF() {
 var doc = new jsPDF();  //create jsPDF object
  doc.fromHTML(document.getElementById("test"), // page element which you want to print as PDF
  15,
  15, 
  {
    ''width'': 2480  //set width
  },
  function(a) 
   {
    doc.save("collage.pdf");
  });
}
</script>
</head>');

htp.p('<style>
  table{
    max-width: 2480px;
    width:100%;
  }
  table, th, td {
    width: auto;
    overflow: hidden;
    word-wrap: break-word;
    border: 1px solid black; 
    border-collapse: collapse;
  }
</style>
<a href="javascript:generatePDF()">PDF</a>
<div id ="test">
<table>');
for i in 
    (
    select  *
    from    vw_questions
    where   (p_id       is null or (p_id      is not null and     test_paper_id     =          p_id))
    and     (p_subj     is null or (p_subj    is not null and ':'||p_subj||':'      like '%:'||subject||':%'))
    and     (p_theme    is null or (p_theme   is not null and ':'||p_theme||':'     like '%:'||theme||':%'))
    and     (p_chapter  is null or (p_chapter is not null and ':'||p_chapter||':'   like '%:'||chapter||':%'))
    order by scan_id, section, question_id
    )
loop
    htp.p('<tr><td>#'||i.section||'/'|| i.question_number || ' [' || i.scan_id || '] [' || i.test_name || ']' || '</br><br><br> <img src="');
    for j in (select screenshot from questions where id = i.question_id) loop
        htpprn(j.screenshot);
    end loop;
    htp.p('"/><br><br><br><br><br><br></td></tr>');
    l_num := l_num+1;
    if l_num > l_max then
        exit;
    end if;
end loop;
htp.p('</table>');
if l_num > l_max then htp.p('Maximum of ' || l_max || ' questions reached'); end if;
htp.p('</div></html>');
end;
/
create or replace PROCEDURE HTPPRN(PCLOB IN OUT NOCOPY CLOB) 
IS
    V_TEMP VARCHAR2(32767);
    V_CLOB CLOB := PCLOB;
    V_AMOUNT NUMBER := 32000;
    V_OFFSET NUMBER := 1;
    V_LENGTH NUMBER := DBMS_LOB.GETLENGTH(PCLOB);
    V_RESULT CLOB;
BEGIN
    WHILE V_LENGTH >= V_OFFSET LOOP
        V_TEMP:= DBMS_LOB.SUBSTR(V_CLOB, V_AMOUNT, V_OFFSET);
        HTP.PRN(V_TEMP);
        V_OFFSET := V_OFFSET + LENGTH(V_TEMP);
    END LOOP;
END;
/
create or replace procedure PR_EDIT_IMAGE (P_QUESTION_ID in VARCHAR2)
as
c clob;
b boolean := false;
begin
for j in (select img from tb_img where id = P_QUESTION_ID)
loop
    c := j.img;
    b := true;
    exit;
end loop;
if not b then
    for j in (select img_data from tb_edited_img where question_id = p_question_id)
    loop
        c := j.img_data;
        b := true;
        exit;
    end loop;
end if;
if not b then
    for j in (select screenshot from questions where id = P_QUESTION_ID) loop
        c := j.screenshot;
        exit;
    end loop;
end if;
htp.p('<!DOCTYPE html>
<html>
<head>
  <title>Answer Sheet Image Editor</title>
</head>
<body>
  <h2>Image Editor</h2>
  <div>
    <button id="saveImg">Save</button>
    <input type="number" id="eraserSize" min="1" max="100" value="30" style="width: 40px; margin-left: 10px;">
    <input type="color" id="colorPicker" value="#FFFFFF">
  </div>
  <div style="position: relative;">
    <canvas id="canvas">
  </div>
  <script>
    const canvas = document.getElementById(''canvas'');
    const ctx = canvas.getContext(''2d'');
    let eraserSize = 10;
    let currentColor = ''#FFFFFF'';

	function updateEraserCursor() {
  const colorPicker = document.getElementById(''colorPicker'');
  const eraserSize = document.getElementById(''eraserSize'').value;
  colorPicker.style.width = `${eraserSize}px`;
  colorPicker.style.height = `${eraserSize}px`;
  colorPicker.style.padding = ''0'';
	      const cursorStyle = `url("data:image/svg+xml;utf8,<svg xmlns=''http://www.w3.org/2000/svg'' width=''${eraserSize}'' height=''${eraserSize}''><rect width=''100%'' height=''100%'' fill=''%23fff'' stroke=''%23000'' stroke-width=''1''/></svg>") ${eraserSize / 2} ${eraserSize / 2}, auto`;
	      canvas.style.cursor = cursorStyle;
	    }

function handleDrawing(event) {
  if (event.buttons === 1) {
    const x = event.offsetX;
    const y = event.offsetY;
    ctx.globalCompositeOperation = ''source-over'';
    ctx.fillStyle = currentColor;
    const halfEraserSize = eraserSize / 2;
    ctx.fillRect(x - halfEraserSize, y - halfEraserSize, eraserSize, eraserSize);
  }
}
    function setEraserSize() {
      eraserSize = parseInt(document.getElementById(''eraserSize'').value);
      updateEraserCursor();
    }

    function setColor() {
      currentColor = document.getElementById(''colorPicker'').value;
    }

function saveImage(){
    var dataUrl = canvas.toDataURL();
    var xhr = new XMLHttpRequest();
      xhr.open("POST", "/ords/psle/save_edited_img/'||p_question_id||'");
      xhr.setRequestHeader("Accept", "application/json");
      xhr.setRequestHeader("Content-Type", "application/json");
      xhr.onreadystatechange = function () {
         if (xhr.readyState === 4) {
            console.log(xhr.responseText);
            //alert(xhr.responseText);
            window.close();
         }
       };
      xhr.send(dataUrl);
}

 document.getElementById(''saveImg'').addEventListener(''click'', saveImage);
    document.getElementById(''eraserSize'').addEventListener(''input'', setEraserSize);
    document.getElementById(''colorPicker'').addEventListener(''input'', setColor);
    const image = new Image();
    let imageWidth, imageHeight;
	image.src =`');
        htpprn(c);    
    htp.p('`;
    image.onload = function() {
      imageWidth = image.width;
      imageHeight = image.height;
      canvas.width = imageWidth;
      canvas.height = imageHeight;
      ctx.drawImage(image, 0, 0, canvas.width, canvas.height);
      canvas.style.pointerEvents = ''auto'';
      canvas.addEventListener(''mousedown'', handleDrawing);
      canvas.addEventListener(''mousemove'', handleDrawing);
    };
    setEraserSize();
  </script>
</body>
</html>
');
end;
/
create or replace procedure  pr_post_login
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



















create or replace TRIGGER  "WKSP_PSLE"."TR_QUESTIONS" 
    before insert or update on wksp_psle.questions
    for each row
begin
    if :new.id is null then
        :new.id := nvl(:new.screenshot_id,sys_guid());
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
create or replace TRIGGER  "WKSP_PSLE"."TR_QUIZ" 
    before insert or update on wksp_psle.tb_quiz
    for each row
declare
    n number;
begin
    if :new.quiz_id is null then
        :new.quiz_id := sys_guid();
    end if;
    if :new.created_on is null then
    :new.created_on := sysdate;
    end if;
end;
/
create or replace TRIGGER "WKSP_PSLE"."TR_SUBJECTS" 
    before insert or update on wksp_psle.subjects
    for each row
begin
    if :new.id is null then
        :new.id := sys_guid();
    end if;
end;
/
create or replace TRIGGER "WKSP_PSLE"."TR_TEST_PAPERS" 
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




  CREATE OR REPLACE FORCE EDITIONABLE VIEW "VW_MARKS" ("ID", "SUBJECT", "SECTION", "TOTAL_MARKS", "TOTAL_QUESTIONS", "TEST_PAPER_ID", "T", "MARKS_LOST", "QUESTIONS_RECORDED", "MARKS_SCORED") DEFAULT COLLATION "USING_NLS_COMP"  AS 
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
) a order by section;

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "VW_QUESTIONS" ("TEST_PAPER_ID", "TEST_NAME", "SUBJECT", "TEST_YEAR", "SECTION", "QUESTION_ID", "QUESTION_NUMBER", "CHAPTER", "THEME", "MARKS_LOST", "SCAN_ID", "SECOND_ATTEMPT", "SHORT_KEY", "ANSWER_KEY", "NUMBER_OF_ATTEMPTS", "CATEGORY", "EDITED_IMG_AVAILABLE", "MCQ", "IMG_AVAILABLE", "LEN_ANSWER") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select  a.test_paper_id, 
  case when c.TEST_NAME like c.scan_id||'%' then c.TEST_NAME else c.scan_id||'_'||c.test_name end TEST_NAME, 
  c.subject, c.test_year, a.section, a.id question_id,
a.question_number, a.chapter, b.theme ,  1 marks_lost, scan_id, nvl(second_attempt,'N') second_attempt,
scan_id||'/'||a.question_number short_key,
a.answer_key,
a.number_of_attempts,
a.category,
nvl((select 'Y' from TB_EDITED_IMG e where e.question_id = a.id and rownum=1),'N') edited_img_available,
mcq,
case when screenshot is null then 'N' else 'Y' end img_available,
length(answer_key) len_answer
from wksp_psle.questions a, WKSP_PSLE.SUBJECTS  b, wksp_psle.test_papers c
where a.chapter = b.chapter
and c.id = a.test_paper_id 
and b.subject = c.subject 
order by scan_id, section, question_id--1,2,3,4,5,7;

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "VW_TEST_PAPERS" ("ID", "TEST_NAME", "TEST_YEAR", "DATE_TAKEN", "SCAN_LINK", "MARKS", "REMARKS", "CREATED_BY", "CREATED_ON", "SUBJECT", "WRONG_QUESTIONS_SCAN", "SCAN_ID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select "ID","TEST_NAME","TEST_YEAR","DATE_TAKEN","SCAN_LINK","MARKS","REMARKS","CREATED_BY","CREATED_ON","SUBJECT","WRONG_QUESTIONS_SCAN","SCAN_ID" from test_papers order by scan_id desc;

  CREATE OR REPLACE EDITIONABLE TRIGGER "TR_QUESTIONS" 
    before insert or update on wksp_psle.questions
    for each row
begin
    if :new.id is null then
        :new.id := nvl(:new.screenshot_id,sys_guid());
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
ALTER TRIGGER "TR_QUESTIONS" ENABLE;

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "TR_SUBJECTS" 
    before insert or update on wksp_psle.subjects
    for each row
begin
    if :new.id is null then
        :new.id := sys_guid();
    end if;
end;
/
ALTER TRIGGER "TR_SUBJECTS" ENABLE;

  CREATE OR REPLACE EDITIONABLE TRIGGER "TR_QUIZ" 
    before insert or update on wksp_psle.tb_quiz
    for each row
declare
    n number;
begin
    if :new.quiz_id is null then
        :new.quiz_id := sys_guid();
    end if;
    if :new.created_on is null then
    :new.created_on := sysdate;
    end if;
end;
/
ALTER TRIGGER "TR_QUIZ" ENABLE;

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "TR_TEST_PAPERS" 
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
ALTER TRIGGER "TR_TEST_PAPERS" ENABLE;
Rem No database link found to generate DDL.



























  CREATE UNIQUE INDEX "SYS_IL0000094980C00005$$" ON "QUESTIONS" (
  ;

  CREATE OR REPLACE EDITIONABLE TRIGGER "TR_QUESTIONS" 
    before insert or update on wksp_psle.questions
    for each row
begin
    if :new.id is null then
        :new.id := nvl(:new.screenshot_id,sys_guid());
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
ALTER TRIGGER "TR_QUESTIONS" ENABLE;

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "TR_SUBJECTS" 
    before insert or update on wksp_psle.subjects
    for each row
begin
    if :new.id is null then
        :new.id := sys_guid();
    end if;
end;
/
ALTER TRIGGER "TR_SUBJECTS" ENABLE;

  CREATE UNIQUE INDEX "SYS_C0042379" ON "TB_EDITED_IMG" ("QUESTION_ID") 
  ;
  CREATE UNIQUE INDEX "SYS_IL0000116933C00002$$" ON "TB_EDITED_IMG" (
  ;

  CREATE UNIQUE INDEX "SYS_IL0000095077C00002$$" ON "TB_IMG" (
  ;

  CREATE UNIQUE INDEX "SYS_C0042491" ON "TB_QUIZ" ("QUIZ_ID") 
  ;
  CREATE UNIQUE INDEX "SYS_IL0000117637C00008$$" ON "TB_QUIZ" (
  ;
  CREATE UNIQUE INDEX "SYS_IL0000117637C00007$$" ON "TB_QUIZ" (
  ;
  CREATE UNIQUE INDEX "SYS_IL0000117637C00006$$" ON "TB_QUIZ" (
  ;
  CREATE UNIQUE INDEX "SYS_IL0000117637C00005$$" ON "TB_QUIZ" (
  ;
  CREATE UNIQUE INDEX "SYS_IL0000117637C00004$$" ON "TB_QUIZ" (
  ;
  CREATE UNIQUE INDEX "SYS_IL0000117637C00003$$" ON "TB_QUIZ" (
  ;

  CREATE OR REPLACE EDITIONABLE TRIGGER "TR_QUIZ" 
    before insert or update on wksp_psle.tb_quiz
    for each row
declare
    n number;
begin
    if :new.quiz_id is null then
        :new.quiz_id := sys_guid();
    end if;
    if :new.created_on is null then
    :new.created_on := sysdate;
    end if;
end;
/
ALTER TRIGGER "TR_QUIZ" ENABLE;

  CREATE UNIQUE INDEX "SYS_C0042492" ON "TB_QUIZ_QUESTIONS" ("ID") 
  ;
  CREATE INDEX "IND_QUIZ_QUESTION_ID" ON "TB_QUIZ_QUESTIONS" ("QUIZ_ID", "QUESTION_ID") 
  ;

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "TR_TEST_PAPERS" 
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
ALTER TRIGGER "TR_TEST_PAPERS" ENABLE;

















































