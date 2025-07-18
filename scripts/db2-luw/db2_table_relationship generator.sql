-- DB2 Table Relationship Discovery Query
-- Identifies potential parent-child relationships between tables based on column naming patterns
-- Parameters: Replace 'YOUR_SCHEMA_NAME' with your target schema name

WITH source_schema AS (
    -- Define source schema to analyze - modify this value
    SELECT '<YOUR_SCHEMA>' AS schema_name FROM SYSIBM.SYSDUMMY1
),
table_columns AS (
    -- Get all columns from the specified schema
    SELECT
        TABSCHEMA AS schema_name,
        TABNAME AS table_name,
        COLNAME AS column_name,
        TYPENAME AS data_type,
        LENGTH AS column_length
    FROM SYSCAT.COLUMNS
    WHERE TABSCHEMA = (SELECT schema_name FROM source_schema)
),
table_relationships AS (
    -- Identify potential parent-child relationships based on column naming patterns
    SELECT DISTINCT
        t1.schema_name AS parent_schema,
        t1.table_name AS parent_table,
        t2.schema_name AS child_schema,
        t2.table_name AS child_table,
        -- Calculate relationship confidence score
        MAX(CASE
            -- Exact column name match with ID in name
            WHEN t1.column_name = t2.column_name AND
                 (t1.column_name LIKE '%ID' OR t1.column_name LIKE '%_ID') THEN 90

            -- Child column follows TableName_ID pattern
            WHEN t2.column_name = UPPER(t1.table_name) || '_ID' THEN 85
            WHEN t2.column_name = LOWER(t1.table_name) || '_id' THEN 85

            -- Child column follows TableNameID pattern
            WHEN t2.column_name = UPPER(t1.table_name) || 'ID' THEN 80
            WHEN t2.column_name = LOWER(t1.table_name) || 'id' THEN 80

            -- Child column has _ID suffix and prefix matches parent table name
            WHEN t2.column_name LIKE '%_ID' AND
                 UPPER(REPLACE(t2.column_name, '_ID', '')) = UPPER(t1.table_name) THEN 75

            -- Child column has ID suffix and prefix matches parent table name
            WHEN t2.column_name LIKE '%ID' AND
                 UPPER(REPLACE(t2.column_name, 'ID', '')) = UPPER(t1.table_name) THEN 70

            -- Exact column name match
            WHEN t1.column_name = t2.column_name THEN 65

            -- Child column has _ID suffix
            WHEN t2.column_name LIKE '%_ID' THEN 60

            -- Child column has ID suffix
            WHEN t2.column_name LIKE '%ID' THEN 55

            -- Other potential relationships
            ELSE 50
        END) AS confidence_score,
        -- Count how many columns suggest this relationship
        COUNT(*) AS matching_column_count
    FROM table_columns t1
    JOIN table_columns t2
    ON (t1.schema_name = t2.schema_name)
    AND t1.table_name != t2.table_name
    AND t1.data_type = t2.data_type
    AND t1.column_length = t2.column_length
    WHERE (
        -- Common relationship patterns
        t1.column_name = t2.column_name
        OR t2.column_name = UPPER(t1.table_name) || '_ID'
        OR t2.column_name = LOWER(t1.table_name) || '_id'
        OR t2.column_name = UPPER(t1.table_name) || 'ID'
        OR t2.column_name = LOWER(t1.table_name) || 'id'
        OR (t2.column_name LIKE '%_ID' AND UPPER(REPLACE(t2.column_name, '_ID', '')) = UPPER(t1.table_name))
        OR (t2.column_name LIKE '%ID' AND UPPER(REPLACE(t2.column_name, 'ID', '')) = UPPER(t1.table_name))
        OR t2.column_name LIKE '%_ID'
        OR t2.column_name LIKE '%ID'
    )
    GROUP BY t1.schema_name, t1.table_name, t2.schema_name, t2.table_name
),
-- Deduplicate relationships to avoid showing both A→B and B→A
deduplicated_relationships AS (
    SELECT
        r1.*
    FROM table_relationships r1
    LEFT JOIN table_relationships r2 ON
        r1.parent_schema = r2.child_schema AND
        r1.parent_table = r2.child_table AND
        r1.child_schema = r2.parent_schema AND
        r1.child_table = r2.parent_table AND
        -- When we have a bidirectional relationship, keep only one direction
        -- based on either higher confidence score or alphabetical order if scores are equal
        (r1.confidence_score < r2.confidence_score OR
         (r1.confidence_score = r2.confidence_score AND r1.parent_table > r1.child_table))
    WHERE r2.parent_table IS NULL
)
-- Final output with relationship classification
SELECT
    parent_schema,
    parent_table,
    child_schema,
    child_table,
    confidence_score,
    matching_column_count,
    CASE
        WHEN confidence_score >= 80 THEN 'Strong relationship'
        WHEN confidence_score >= 70 THEN 'Likely relationship'
        WHEN confidence_score >= 60 THEN 'Possible relationship'
        ELSE 'Weak relationship'
    END AS relationship_strength
FROM deduplicated_relationships
WHERE confidence_score >= 60  -- Adjust threshold as needed
ORDER BY confidence_score DESC, matching_column_count DESC, parent_schema, parent_table, child_schema, child_table;
