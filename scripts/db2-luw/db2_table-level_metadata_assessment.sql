-- Systematically scans the database to:
-- 1 -> Discover all user-defined tables (excluding system tables)
  -- 1.1 -> Schema name (TABSCHEMA)
  -- 1.2 -> Table name (TABNAME)
  -- 1.3 -> Whether the table participates in data replication (DATACAPTURE)
          -- 1.3.1 -> Y → Table is configured to log full row changes for replication tools
          -- 1.3.2 -> N → Table does not log changes for replication
  -- 1.4 -> Estimated row count (CARD)
  -- 1.5 -> Total number of columns (COLCOUNT)
  -- 1.6 -> Table creation date (CREATE_TIME)
  -- 1.7 -> Last schema change timestamp (ALTER_TIME)
  -- 1.8 -> Whether table is clustered (CLUSTERED)
  -- 1.9 -> Compression mode (COMPRESSION)
  -- 1.10 -> Append mode flag (APPEND_MODE)
  -- 1.11 -> Number of columns in the primary key (KEYCOLUMNS)
  -- 1.12 -> Number of unique constraints (KEYUNIQUE)
  -- 1.13 -> Number of check constraints (CHECKCOUNT)
  -- 1.14 -> Number of parent tables linked via foreign keys (PARENTS)
  -- 1.15 -> Number of child tables depending on this table (CHILDREN)
--TODO -  SELECT DISTINCT TABSCHEMA, TABNAME FROM SYSCAT.DATAPARTITIONS WHERE TABNAME  ='DEPARTMENT'
-- TODO -  LOAD SAMPLE DB - HAVE OPTION TO LOAD SAMPLE OR NOT. IF SAMPLE LOADED don't create custom DB
  SELECT
    T.TABSCHEMA               AS SCHEMA_NAME,
    T.TABNAME                 AS TABLE_NAME,
    T.DATACAPTURE             AS REPLICATION_ENABLED,
    T.CARD                    AS EST_ROW_COUNT,
    T.COLCOUNT                AS COLUMN_COUNT,
    T.CREATE_TIME             AS CREATED_ON,
    T.ALTER_TIME              AS LAST_MODIFIED_ON,
    T.CLUSTERED               AS IS_CLUSTERED,
    T.COMPRESSION             AS COMPRESSION_MODE,
    T.APPEND_MODE             AS APPEND_MODE,
    T.KEYCOLUMNS              AS PRIMARY_KEY_COLUMNS,
    T.KEYUNIQUE               AS UNIQUE_CONSTRAINTS,
    T.CHECKCOUNT              AS CHECK_CONSTRAINTS,
    T.PARENTS                 AS PARENT_TABLES,
    T.CHILDREN                AS CHILD_TABLES
  FROM
    SYSCAT.TABLES T
  WHERE
    T.TYPE = 'T'
    AND T.TABSCHEMA NOT LIKE 'SYS%'
  ORDER BY
    T.TABSCHEMA, T.TABNAME;
