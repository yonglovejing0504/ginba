様式マッピングリスト,サプライヤ固有物件情報_リース,ビュー_取扱店別支払金額集計,ビュー_契約別支払金額集計

--■COPYテーブル(結構・データ)
CREATE TABLE SCD_UN1M001_BAK AS SELECT * FROM SCD_UN1M001;
--■テーブル名前変更
ALTER TABLE UN2M002 RENAME TO UN2M002_BAK;
--■唯一索引
CREATE INDEX INDEX_NAME ON TABLE_NAME(XXX);
--■非唯一索引（disable novalidate）
CREATE UNIQUE INDEX INDEX_NAME ON TABLE_NAME(XXX);
--■テーブル分析
ANALYZE TABLE UN1M005 COMPUTE STATISTICS;
--■INDEX分析
ALTER INDEX INDEX_UN1M005 MONITORING USAGE;
--■取得所有表的件数
SELECT T.TABLE_NAME,T.NUM_ROWS FROM USER_TABLES T
--■取得システム時間
SELECT TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS') FROM DUAL;

TRUNCATE  TABLE  table;
ALTER TABLE CHANGEACC2SPLUS DROP (SEQ_NO);


--■カラム追加
ALTER TABLE API_LOG ADD ANKSPLHONHANCD     CHAR(9);
--■カラム属性更新
ALTER TABLE UN2M003 MODIFY KNJSTRNAMN      VARCHAR2(160);
--■カラム名前変更
ALTER TABLE UN2M003 RENAME COLUMN USERNO TO USERNO_BAK;
--■カラム削除
ALTER TABLE UN2M026 DROP (GRADEUP);
--■削除表主キー
ALTER TABLE UN2M055 DROP CONSTRAINT PK_UN2M055_NEW;
--■追加表主キー
ALTER TABLE UN1M005 ADD SEQ_NO NUMBER(15,0) GENERATED ALWAYS AS IDENTITY;
--主キー名前変更
ALTER TABLE UN1M001 DROP CONSTRAINT PK_UN1M001_NEW;
ALTER TABLE UN1M001 ADD CONSTRAINT PK_UN1M001 PRIMARY KEY(ANKACCOUNTID);

DROP PROCEDURE IF EXISTS `funa`;


--■半角→全角へ転換--契約者名（カナ）
UPDATE UN1M009 SET ANKKEINAM=TO_MULTI_BYTE(UTL_I18N.TRANSLITERATE(TRIM(ANKKEINAM_BAK),'HWKATAKANA_FWKATAKANA'));

--■DEFAULT値
ALTER TABLE UN2M003 MODIFY ANKMSTRFLG DEFAULT 0;

--■コードマッピング
MERGE INTO UN1M005 USING T_M_CUSTOMER_CD
ON ( TRIM(UN1M005.ANKSTORECODE) = TRIM(T_M_CUSTOMER_CD.CUSTOMER_CD_OLD))
WHEN MATCHED THEN UPDATE SET
ANKSPLHONHANCD = T_M_CUSTOMER_CD.CUSTOMER_CD_NEW,
ANKSPLBUEGYCD = T_M_CUSTOMER_CD.DEPT_CD;


--■INDEX検索
SELECT I.INDEX_NAME,
       I.INDEX_TYPE,
       I.TABLE_OWNER,
       I.TABLE_NAME,
       I.UNIQUENESS,
       I.TABLESPACE_NAME,
       C.COLUMN_NAME,
       C.COLUMN_POSITION,
       C.COLUMN_LENGTH
FROM USER_INDEXES I, USER_IND_COLUMNS C
WHERE I.INDEX_NAME = C.INDEX_NAME;

--■無効なテーブル削除
DECLARE
  I INTEGER;
BEGIN
  FOR TODROP IN 
      (
	      SELECT TABLE_NAME
	      FROM USER_TABLES
	      WHERE
		    table_name LIKE '#%'
		    OR table_name LIKE '%BAK%'
		    OR table_name LIKE '%$_201%'  escape '$'
		    OR table_name LIKE '%_BK%'
		    OR table_name  LIKE '%$_15%' escape '$' 
		    OR table_name  LIKE '%$_18%' escape '$'
      ) LOOP
      EXECUTE IMMEDIATE 'DROP TABLE "' || TODROP.TABLE_NAME || '"';
  END LOOP;
END;

--■性能改善、テーブルの統計情報
EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME => 'SCDSTCHG', TABNAME => 'API_LOG',ESTIMATE_PERCENT => 1, CASCADE => TRUE); 

--■所有テーブル名取得
SELECT * FROM USER_TAB_COMMENTS WHERE TABLE_NAME NOT LIKE '#%';

--■SQL Developerのログ出力
SET SERVEROUTPUT ON
DBMS_OUTPUT.PUT_LINE('UPDATE件数 = ' || v_update_count);

--■主キー設定前、重複データチェック
SELECT TOKEN_ID キー,COUNT(*) CNT FROM OAUTH_REFRESH_TOKEN GROUP BY TOKEN_ID HAVING COUNT(*) > 1

--■検索権限付与
GRANT SELECT ON UN2M003 TO SCDDT003;
CREATE OR REPLACE EDITIONABLE SYNONYM "SCDDT003"."UN2M003" FOR "SCDDM003"."UN2M003";

--■SQLPLUS
SET NLS_LANG=JAPANESE_JAPAN.JA16SJISTILDE
SQLPLUS SCDDM003/DEV_bt18SCD@10.103.25.3:1521/DEVSCD


--■項目属性取得
SELECT
       A.TABLE_NAME AS "TABLENAME",
       CASE WHEN (SELECT COUNT(*) FROM USER_VIEWS V WHERE V.VIEW_NAME =A.TABLE_NAME )>0 THEN 'V' ELSE 'U'END AS "TABLETYPE",
       A.COLUMN_NAME AS "COLUMNNAME",
       A.COLUMN_ID AS "COLUMNINDEX",
       A.DATA_TYPE AS "DATATYPE",
       CASE  
         WHEN A.DATA_TYPE = 'NUMBER' THEN
           CASE WHEN A.DATA_PRECISION IS NULL THEN
             A.DATA_LENGTH
             ELSE 
               A.DATA_PRECISION
               END 
         ELSE
          A.DATA_LENGTH
       END AS "LENGTH",
       CASE WHEN A.NULLABLE = 'N' THEN  '0' ELSE '1' END AS "ISNULLABLE",
       B.COMMENTS AS "DESCRIPTION", 
       CASE
          WHEN (SELECT COUNT(*) FROM USER_CONS_COLUMNS C 
            WHERE C.TABLE_NAME=A.TABLE_NAME AND C.COLUMN_NAME=A.COLUMN_NAME AND C.CONSTRAINT_NAME=
                (SELECT D.CONSTRAINT_NAME FROM USER_CONSTRAINTS D WHERE D.TABLE_NAME=C.TABLE_NAME AND D.CONSTRAINT_TYPE   ='P')
                 )>0 THEN '1' ELSE '0'END AS "ISPK"
            
  FROM USER_TAB_COLS A,
       SYS.USER_COL_COMMENTS B
 WHERE A.TABLE_NAME = B.TABLE_NAME      
       AND B.COLUMN_NAME = A.COLUMN_NAME       
       ORDER BY A.TABLE_NAME, A.COLUMN_ID
       
       
       
show PARAMETER instance name;
select * from v$sga;


--テーブル表領域利用状況
SELECT TOTAL.TABLESPACE_NAME,
       ROUND(TOTAL.MB, 2)/1024 AS TOTAL_GB,
       ROUND(TOTAL.MB - FREE.MB, 2)/1024 AS USED_GB,
       ROUND((1 - FREE.MB / TOTAL.MB) * 100, 2) || '%' AS USED_PCT,
       ROUND(FREE.MB, 2)/1024 AS FREE_GB
  FROM (SELECT A.TABLESPACE_NAME, SUM(A.BYTES) / 1024 / 1024 AS MB
          FROM SYS.DBA_DATA_FILES A
         GROUP BY A.TABLESPACE_NAME) TOTAL,
       (SELECT B.TABLESPACE_NAME,
               COUNT(1) AS EXTENDS,
               SUM(B.BYTES) / 1024 / 1024 AS MB,
               SUM(B.BLOCKS) AS BLOCKS
          FROM SYS.DBA_FREE_SPACE B
         GROUP BY B.TABLESPACE_NAME) FREE
 WHERE TOTAL.TABLESPACE_NAME = FREE.TABLESPACE_NAME;




--一時表領域利用状況
SELECT TABLESPACE_NAME,FILE_ID,FILE_NAME,BYTES / 1024/1024/1024 AS "SPACE(G)"
  FROM DBA_TEMP_FILES;



--INDEX 取得
SELECT TABLE_NAME,INDEX_NAME, COLUMN_POSITION,  COLUMN_NAME
  FROM USER_IND_COLUMNS
WHERE INDEX_NAME NOT LIKE '%PK%'
ORDER BY TABLE_NAME,INDEX_NAME, COLUMN_POSITION


https://www.cnblogs.com/march3/archive/2009/07/23/1529442.html

SET SERVEROUTPUT ON;
DECLARE
    V_KNJSTRNAMN UN2M003.KNJSTRNAMN%TYPE;
    V_ANKSPLHONHANCD UN2M003.ANKSPLHONHANCD%TYPE;
    V_ANKSPLBUEGYCD  UN2M003.ANKSPLBUEGYCD%TYPE;

    STRKNJSTRNAMN VARCHAR(200);
    
    
    CURSOR MYCUR IS SELECT KNJSTRNAMN,ANKSPLHONHANCD,ANKSPLBUEGYCD FROM UN2M003 WHERE ROWNUM <10;
BEGIN
    OPEN MYCUR;

    FETCH MYCUR INTO V_KNJSTRNAMN,V_ANKSPLHONHANCD,V_ANKSPLBUEGYCD;
    
    WHILE MYCUR%FOUND LOOP
    
        STRKNJSTRNAMN :=V_KNJSTRNAMN;
    
    
        DBMS_OUTPUT.PUT_LINE(V_KNJSTRNAMN || V_ANKSPLHONHANCD || V_ANKSPLBUEGYCD || STRKNJSTRNAMN);
        FETCH MYCUR INTO V_KNJSTRNAMN,V_ANKSPLHONHANCD,V_ANKSPLBUEGYCD;
    END LOOP;
    CLOSE MYCUR;
END;