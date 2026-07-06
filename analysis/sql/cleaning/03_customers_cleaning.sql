/*
====================================================================
File: 03_customers_cleaning.sql
====================================================================

Purpose
-------
Standardize customer city names before analysis.

Cleaning tasks:
• Identify inconsistent city names using fuzzy matching
• Correct confirmed spelling inconsistencies
• Verify the updates

====================================================================
*/

BEGIN;

------------------------------------------------------------
-- 1. Enable Fuzzy String Matching
------------------------------------------------------------

CREATE EXTENSION IF NOT EXISTS pg_trgm;

------------------------------------------------------------
-- 2. Investigate Similar City Names
------------------------------------------------------------

SELECT
    a.customer_city AS city_1,
    b.customer_city AS city_2,
    similarity(a.customer_city, b.customer_city) AS similarity_score
FROM
    (SELECT DISTINCT customer_city FROM customers) a,
    (SELECT DISTINCT customer_city FROM customers) b
WHERE
    a.customer_city < b.customer_city
    AND similarity(a.customer_city, b.customer_city) > 0.8
ORDER BY similarity_score DESC;

------------------------------------------------------------
-- 3. Standardize Confirmed City Name Inconsistencies
------------------------------------------------------------

UPDATE customers
SET customer_city = 'campo belo'
WHERE customer_city = 'belo campo';

UPDATE customers
SET customer_city = 'mogi mirim'
WHERE customer_city = 'mogi-mirim';

UPDATE customers
SET customer_city = 'pires do rio'
WHERE customer_city = 'rio do pires';

UPDATE customers
SET customer_city = 'estrela d''oeste'
WHERE customer_city = 'estrela d oeste';

UPDATE customers
SET customer_city = 'sao jorge do oeste'
WHERE customer_city = 'sao jorge d''oeste';

UPDATE customers
SET customer_city = 'palmeira d''oeste'
WHERE customer_city = 'palmeira d oeste';

UPDATE customers
SET customer_city = 'dias d''avila'
WHERE customer_city = 'dias d avila';

UPDATE customers
SET customer_city = 'arraial d''ajuda'
WHERE customer_city = 'arraial d ajuda';

------------------------------------------------------------
-- 4. Verify Results
------------------------------------------------------------

SELECT
    customer_city,
    COUNT(*) AS customers
FROM customers
WHERE customer_city IN (
    'campo belo',
    'mogi mirim',
    'pires do rio',
    'estrela d''oeste',
    'sao jorge do oeste',
    'palmeira d''oeste',
    'dias d''avila',
    'arraial d''ajuda'
)
GROUP BY customer_city
ORDER BY customer_city;

COMMIT;

/*
====================================================================
Cleaning Summary

• Customer city names were standardized using fuzzy matching.
• Only confirmed inconsistencies were corrected.
• Legitimate cities with similar names were intentionally left
  unchanged to preserve data integrity.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
