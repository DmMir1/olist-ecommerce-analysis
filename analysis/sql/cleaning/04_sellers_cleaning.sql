/*
====================================================================
File: 04_sellers_cleaning.sql
====================================================================

Purpose
-------
Standardize seller city names before analysis.

Cleaning tasks:
• Standardize inconsistent city names
• Remove state codes and duplicate formatting
• Normalize whitespace
• Fix Unicode encoding inconsistencies
• Verify the results

====================================================================
*/

BEGIN;

------------------------------------------------------------
-- 1. Standardize Seller City Names
------------------------------------------------------------

UPDATE sellers
SET seller_city = 'sao paulo'
WHERE seller_city IN (
    'sao paulo sp',
    'sao paulo - sp',
    'sao paulo / sao paulo',
    'sao  paulo',
    'sp / sp'
);

UPDATE sellers
SET seller_city = 'rio de janeiro'
WHERE seller_city IN (
    'rio de janeiro / rio de janeiro',
    'rio de janeiro \rio de janeiro'
);

UPDATE sellers
SET seller_city = 'belo horizonte'
WHERE seller_city = 'belo horizont';

UPDATE sellers
SET seller_city = 'angra dos reis'
WHERE seller_city = 'angra dos reis rj';

UPDATE sellers
SET seller_city = 'sao jose do rio preto'
WHERE seller_city IN (
    'sao jose do rio pret',
    's jose do rio preto'
);

UPDATE sellers
SET seller_city = 'mogi das cruzes'
WHERE seller_city = 'mogi das cruzes / sp';

UPDATE sellers
SET seller_city = 'pinhais'
WHERE seller_city = 'pinhais/pr';

UPDATE sellers
SET seller_city = 'unknown'
WHERE seller_city = '04482255';

------------------------------------------------------------
-- 2. Normalize Whitespace
------------------------------------------------------------

UPDATE sellers
SET seller_city = REGEXP_REPLACE(seller_city, '\s+', ' ', 'g');

UPDATE sellers
SET seller_city = TRIM(seller_city);

------------------------------------------------------------
-- 3. Fix Unicode Apostrophe Encoding
------------------------------------------------------------

UPDATE sellers
SET seller_city = REPLACE(seller_city, chr(180), chr(39));

------------------------------------------------------------
-- 4. Verify Results
------------------------------------------------------------

SELECT
    seller_city,
    COUNT(*) AS sellers
FROM sellers
WHERE seller_city IN (
    'sao paulo',
    'rio de janeiro',
    'belo horizonte',
    'angra dos reis',
    'sao jose do rio preto',
    'mogi das cruzes',
    'pinhais',
    'unknown'
)
GROUP BY seller_city
ORDER BY seller_city;

COMMIT;

/*
====================================================================
Cleaning Summary

• Seller city names were standardized.
• State abbreviations, duplicate formatting and extra whitespace
  were removed.
• Unicode encoding inconsistencies were corrected.
• Sellers table is ready for downstream analysis.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
