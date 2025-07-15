-- For each table, it extracts column definitions, including:
      -- 2.1 -> Column name (COLNAME)
      -- 2.2 -> Data type (TYPENAME)
      -- 2.3 -> Length (LENGTH)
      -- 2.4 -> Whether the column allows nulls (NULLS)
      -- 2.5 -> Number of Nulls or Empty values (NUMNULLS)
      -- 2.6 -> Estimated number of distinct values (COLCARD)
      -- 2.7 -> Column default value if any (DEFAULT)
      -- 2.8 -> Average Length of values stored in the column (AVGCOLLEN)
      -- 2.9 -> Maximum estimated value stored in column (HIGH2KEY)
      -- 2.10 -> Minimum estimated value stored in column (LOW2KEY)
      -- 2.11 -> Identity column flag (IDENTITY)
      -- 2.12 -> Hidden column flag (HIDDEN)
      -- 2.13 -> Column description from schema (REMARKS)
      -- 2.14 -> Shows the name of the constraint the column participates in (CONSTNAME)
      -- 2.15 -> Indicates the position of the column within the key constraint (COLSEQ)
              -- 2.15.1 -> 1 means it's the first column in the key
              -- 2.15.2 -> 2, 3, etc., indicate later positions in multi-column keys
SELECT
  C.TABSCHEMA               AS SCHEMA_NAME,
  C.TABNAME                 AS TABLE_NAME,
  C.COLNAME                 AS COLUMN_NAME,
  C.TYPENAME                AS DATA_TYPE,
  C.LENGTH                  AS COLUMN_LENGTH,
  C.NULLS                   AS IS_NULLABLE,
  C.NUMNULLS                AS NULL_COUNT,
  C.COLCARD                 AS DISTINCT_VALUES,
  C.DEFAULT                 AS DEFAULT_VALUE,
  C.AVGCOLLEN               AS AVG_LENGTH,
  C.HIGH2KEY                AS MAX_VALUE_ESTIMATE,
  C.LOW2KEY                 AS MIN_VALUE_ESTIMATE,
  C.IDENTITY                AS IS_IDENTITY,
  C.HIDDEN                  AS IS_HIDDEN,
  C.REMARKS                 AS COLUMN_DESCRIPTION,
  K.CONSTNAME               AS CONSTRAINT_NAME,
  K.COLSEQ                  AS KEY_POSITION
FROM
  SYSCAT.COLUMNS C
LEFT JOIN
  SYSCAT.KEYCOLUSE K
    ON C.TABSCHEMA = K.TABSCHEMA AND C.TABNAME = K.TABNAME AND C.COLNAME = K.COLNAME
WHERE
  C.TABSCHEMA NOT LIKE 'SYS%'
ORDER BY
  C.TABSCHEMA, C.TABNAME, C.COLNO;
