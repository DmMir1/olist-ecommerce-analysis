/*
====================================================================
File: 07_category_translation.sql
====================================================================

Purpose
-------
Complete the product category translation table by adding
missing English translations required for reporting.

Cleaning tasks:
• Insert missing category translations
• Add translation for unknown category

====================================================================
*/

BEGIN;

------------------------------------------------------------
-- Insert Missing Category Translations
------------------------------------------------------------

INSERT INTO product_category_name_translation (
    product_category_name,
    product_category_name_english
)
VALUES
(
    'portateis_cozinha_e_preparadores_de_alimentos',
    'portable_kitchen_and_food_processors'
),
(
    'pc_gamer',
    'pc_gamer'
),
(
    'unknown',
    'unknown'
);

------------------------------------------------------------
-- Verify Insert
------------------------------------------------------------

SELECT
    *
FROM product_category_name_translation
WHERE product_category_name IN (
    'portateis_cozinha_e_preparadores_de_alimentos',
    'pc_gamer',
    'unknown'
);

COMMIT;

/*
====================================================================
Cleaning Summary

• Added missing English translations for two product categories.
• Added a translation for the 'unknown' category introduced
  during product cleaning.
• Translation table is ready for reporting and dashboard use.

====================================================================
*/

/*
====================================================================
End of Script
====================================================================
*/
