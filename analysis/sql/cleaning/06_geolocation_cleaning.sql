/*
====================================================================
File: 06_geolocation_cleaning.sql
====================================================================

Purpose
-------
Clean and standardize the geolocation table for reliable
geographic analysis and Power BI reporting.

Cleaning tasks:
• Remove duplicate records
• Normalize city names
• Remove invalid coordinate outliers
• Verify cleaning results

====================================================================
*/

BEGIN;

------------------------------------------------------------
-- 1. Remove Duplicate Geolocation Records
------------------------------------------------------------

-- Create a deduplicated copy of the table using DISTINCT.

CREATE TABLE geolocation_deduplicated AS
SELECT DISTINCT *
FROM geolocation;

-- Replace the original table.

DROP TABLE geolocation;

ALTER TABLE geolocation_deduplicated
RENAME TO geolocation;

------------------------------------------------------------
-- 2. Normalize City Names
------------------------------------------------------------

-- Standardize apostrophes and whitespace.

UPDATE geolocation
SET geolocation_city = REPLACE(geolocation_city, chr(180), chr(39));

UPDATE geolocation
SET geolocation_city = REGEXP_REPLACE(
    geolocation_city,
    '\s+',
    ' ',
    'g'
);

UPDATE geolocation
SET geolocation_city = TRIM(geolocation_city);

------------------------------------------------------------
-- 3. Remove Coordinate Outliers
------------------------------------------------------------

-- Remove coordinates outside the approximate bounds of Brazil.

DELETE FROM geolocation
WHERE geolocation_lat NOT BETWEEN -34 AND 6
   OR geolocation_lng NOT BETWEEN -75 AND -28;

------------------------------------------------------------
-- 4. Verification
------------------------------------------------------------

-- Confirm duplicate removal.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state
    )) AS distinct_rows
FROM geolocation;

-- Verify coordinate ranges.

SELECT
    MIN(geolocation_lat) AS min_lat,
    MAX(geolocation_lat) AS max_lat,
    MIN(geolocation_lng) AS min_lng,
    MAX(geolocation_lng) AS max_lng
FROM geolocation;

COMMIT;

/*
====================================================================
Cleaning Summary

• Duplicate geolocation records removed.
• City names standardized for consistent reporting.
• Unicode and whitespace inconsistencies corrected.
• Invalid geographic coordinate outliers removed.
• Geolocation table prepared for mapping and regional analysis.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
