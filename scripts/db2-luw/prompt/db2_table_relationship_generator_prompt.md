# DB2 Schema Analysis and Relationship Discovery

You are a DB2 database expert specializing in schema analysis and relationship discovery. I need your help to analyze a DB2 database schema and identify potential relationships between tables where no explicit foreign key constraints are defined.

I have access to the DB2 system catalog views. Here's a sample query I can use to list tables and columns:

```sql::list_tables_columns.sql::queries/list_tables_columns.sql
SELECT 
    TABSCHEMA AS TABLE_SCHEMA,
    TABNAME   AS TABLE_NAME,
    COLNAME   AS COLUMN_NAME
FROM SYSCAT.COLUMNS
WHERE TABSCHEMA NOT LIKE 'SYS%'  -- Exclude system schemas
ORDER BY TABSCHEMA, TABNAME, COLNAME;


Please create a SQL query that can identify potential parent-child relationships between tables based on column naming patterns. The query should:

Focus on identifying table-level relationships (parent table → child table)

Eliminate duplicate relationships where tables appear in reverse order (if A→B exists, don't show B→A)

Calculate a confidence score for each relationship

Work with DB2 catalog views and be compatible with DB2 SQL syntax

Allow specifying a schema name parameter

Order results by confidence score (highest first)

The query should look for common relationship patterns such as:

Identical column names across tables

Columns following naming conventions like _ID

Columns with _ID suffixes that might reference other tables

Please provide the complete SQL query in a properly formatted code block with the file name and path specified. Do not use placeholders or omit any parts of the code. The query should be ready to execute without any manual editing.

Important considerations:

We need to avoid duplicate relationships where tables A→B and B→A both appear

We should focus on table-level relationships without including all column details

The query should work even if primary key information is not accessible