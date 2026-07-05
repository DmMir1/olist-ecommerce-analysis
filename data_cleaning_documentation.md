# Data Cleaning Documentation
## Olist E-Commerce Dataset — Brazilian E-Commerce Public Dataset

---

## Overview

This document describes the complete data cleaning process applied to the Olist e-commerce dataset before analysis. The dataset consists of 8 tables with ~100,000 real Brazilian e-commerce transactions from 2016 to 2018.

Every decision made during cleaning follows the **Fix / Flag / Leave** principle:
- **Fix** — when the issue is a clear technical error that would break analysis
- **Flag** — when the data looks suspicious but may be legitimate, so we mark it for filtering
- **Leave** — when the value is legitimate real-world behavior, not an error

---

## Step 1 — Understanding the Structure

Before cleaning anything, I explored each table to understand what every column means and how tables relate to each other.

**Key finding:** The dataset has a clear relational structure with `orders` as the central table. All other tables connect through `order_id`, `customer_id`, `product_id`, or `seller_id`.

**Verification query — row counts across all tables:**
```sql
SELECT 'orders' as table_name, COUNT(*) as rows FROM orders
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers;
```

| Table | Rows |
|---|---|
| orders | 99,441 |
| order_items | 112,650 |
| customers | 99,441 |
| payments | 103,886 |
| reviews | 70,000 |
| products | 32,951 |
| sellers | 3,095 |

---

## Step 2 — Missing Values

### Issue 2.1 — Empty Strings Instead of NULL in Date Columns

**Discovery:** Initial NULL check showed all columns as fully populated. However, a follow-up check for empty strings `''` revealed 2,965 rows with empty delivery dates.

**Root cause:** DBeaver imported empty CSV cells as empty strings `''` instead of proper NULL values. This is a very common real-world data import issue. PostgreSQL's `COUNT()` function skips true NULLs but counts empty strings, which is why the initial check was misleading.

**Lesson learned:** Always check both NULLs AND empty strings separately after importing CSV data.

**Findings:**
| Column | Empty String Count |
|---|---|
| order_delivered_customer_date | 2,965 |
| order_delivered_carrier_date | 1,783 |
| order_approved_at | 160 |

**Decision: Fix** — Empty strings in date columns break all date calculations (delivery time, delays, trends). These are clearly import artifacts, not real values.

```sql
UPDATE orders SET order_approved_at = NULL 
WHERE order_approved_at = '';

UPDATE orders SET order_delivered_carrier_date = NULL 
WHERE order_delivered_carrier_date = '';

UPDATE orders SET order_delivered_customer_date = NULL 
WHERE order_delivered_customer_date = '';
```

### Issue 2.2 — Missing Product Categories

**Findings:** 610 products had empty string `''` as category name.

**Decision: Fix** — Empty category breaks GROUP BY analysis. Set to 'unknown' so these products are still counted in analysis without distorting category groupings.

```sql
UPDATE products SET product_category_name = 'unknown'
WHERE product_category_name = '';
```

### Issue 2.3 — Missing Product Dimensions

**Findings:** 610 products had NULL values in `product_name_lenght` and `product_description_lenght`. 2 products had NULL `product_weight_g`.

**Decision: Leave** — These columns are not used in our core analysis. Setting them to 0 would imply a product has a name with zero characters, which is misleading. Legitimate NULLs.

### Issue 2.4 — Missing Review Comments

**Findings:** 61,728 rows missing `review_comment_title`, 41,118 missing `review_comment_message`.

**Decision: Leave** — Customers are not required to write a comment when leaving a star rating. This is expected real-world behavior, not a data error.

---

## Step 3 — Duplicate Values

Checked primary keys and composite keys across all tables.

```sql
-- Example: checking for duplicate order_ids
SELECT order_id, COUNT(*) as count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;
```

**Result:** Zero duplicates found across all 6 tables checked (orders, customers, products, sellers, order_items, order_payments).

---

## Step 4 — Data Types

**Discovery:** All date columns across 3 tables were imported as `character varying` (text) instead of proper `timestamp` type. This is a critical issue — text-stored dates cannot be used in date calculations, sorting, or time-series analysis.

**Lesson learned:** Always verify data types after CSV import. PostgreSQL does not automatically infer timestamp types from CSV files.

**Affected columns:**

| Table | Column | Problem | Fix |
|---|---|---|---|
| orders | order_purchase_timestamp | text | → timestamp |
| orders | order_approved_at | text | → timestamp |
| orders | order_delivered_carrier_date | text | → timestamp |
| orders | order_delivered_customer_date | text | → timestamp |
| orders | order_estimated_delivery_date | text | → timestamp |
| order_reviews | review_creation_date | text | → timestamp |
| order_reviews | review_answer_timestamp | text | → timestamp |
| order_items | shipping_limit_date | text | → timestamp |

```sql
ALTER TABLE orders
    ALTER COLUMN order_purchase_timestamp TYPE timestamp 
        USING order_purchase_timestamp::timestamp,
    ALTER COLUMN order_approved_at TYPE timestamp 
        USING order_approved_at::timestamp,
    ALTER COLUMN order_delivered_carrier_date TYPE timestamp 
        USING order_delivered_carrier_date::timestamp,
    ALTER COLUMN order_delivered_customer_date TYPE timestamp 
        USING order_delivered_customer_date::timestamp,
    ALTER COLUMN order_estimated_delivery_date TYPE timestamp 
        USING order_estimated_delivery_date::timestamp;
```

---

## Step 5 — Invalid Values

### Issue 5.1 — Logical Date Sequence Violations

**Approach:** Validated that the logical order of events makes sense:
`purchase → approval → carrier pickup → customer delivery`

**Findings:**
| Check | Count |
|---|---|
| Delivery before purchase | 0 ✅ |
| Approval before purchase | 0 ✅ |
| Carrier pickup before approval | 1,359 ⚠️ |
| Customer delivery before carrier pickup | 23 ⚠️ |
| Estimated delivery before purchase | 0 ✅ |

**Investigation:** All 1,382 affected orders have `delivered` status — they were successfully completed. Time differences were small (mostly 1-9 days). This is a known characteristic of the Olist dataset: in Brazil, some sellers physically ship items before the digital approval is recorded in the system. The discrepancy is a logging delay, not a real impossibility.

**Decision: Flag** — These are real transactions with real revenue. Deleting them would distort sales analysis. Instead, added a boolean flag column so they can be optionally excluded from delivery time calculations.

```sql
ALTER TABLE orders ADD COLUMN is_date_sequence_valid boolean;

UPDATE orders SET is_date_sequence_valid = 
    CASE 
        WHEN order_delivered_carrier_date < order_approved_at THEN false
        WHEN order_delivered_customer_date < order_delivered_carrier_date THEN false
        ELSE true
    END;
```

**Result:** 1,382 orders flagged as `false`, 98,059 as `true`.

### Issue 5.2 — Zero Payment Installments

**Finding:** 2 credit card payments had `payment_installments = 0`. A credit card payment must have at least 1 installment.

**Decision: Fix** — Clear data entry error.

```sql
UPDATE order_payments 
SET payment_installments = 1
WHERE payment_installments < 1;
```

### All Other Value Checks Passed

| Check | Result |
|---|---|
| Negative/zero prices | 0 ✅ |
| Negative freight values | 0 ✅ |
| Review scores outside 1-5 | 0 ✅ |
| Negative payment values | 0 ✅ |

---

## Step 6 — Inconsistencies

### Issue 6.1 — City Name Inconsistencies

**Approach:** Used PostgreSQL's `pg_trgm` extension for fuzzy string matching to automatically detect similar city names, rather than relying on manual visual inspection.

```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;

SELECT 
    a.customer_city as city_1,
    b.customer_city as city_2,
    similarity(a.customer_city, b.customer_city) as similarity_score
FROM 
    (SELECT DISTINCT customer_city FROM customers) a,
    (SELECT DISTINCT customer_city FROM customers) b
WHERE 
    a.customer_city < b.customer_city
    AND similarity(a.customer_city, b.customer_city) > 0.8
ORDER BY similarity_score DESC;
```

**Important distinction:** Not all similar-looking city pairs are errors. Brazil has many cities with similar names (e.g. `nova ponte` and `ponte nova` are genuinely different cities). Before fixing any pair, we verified by checking customer counts — a city with 1 customer vs 76 customers with a similar name is likely a typo of the larger city.

**Customers table fixes:**
```sql
UPDATE customers SET customer_city = 'campo belo' WHERE customer_city = 'belo campo';
UPDATE customers SET customer_city = 'mogi mirim' WHERE customer_city = 'mogi-mirim';
UPDATE customers SET customer_city = 'pires do rio' WHERE customer_city = 'rio do pires';
UPDATE customers SET customer_city = 'estrela d''oeste' WHERE customer_city = 'estrela d oeste';
UPDATE customers SET customer_city = 'sao jorge do oeste' WHERE customer_city = 'sao jorge d''oeste';
UPDATE customers SET customer_city = 'palmeira d''oeste' WHERE customer_city = 'palmeira d oeste';
UPDATE customers SET customer_city = 'dias d''avila' WHERE customer_city = 'dias d avila';
UPDATE customers SET customer_city = 'arraial d''ajuda' WHERE customer_city = 'arraial d ajuda';
```

**Sellers table — more severe inconsistencies found:**

The sellers table had significantly more issues including city names with state codes appended, slash-separated duplicates, and truncated names:

```sql
UPDATE sellers SET seller_city = 'sao paulo' WHERE seller_city IN (
    'sao paulo sp', 'sao paulo - sp', 'sao paulo / sao paulo', 'sao  paulo', 'sp / sp'
);
UPDATE sellers SET seller_city = 'rio de janeiro' WHERE seller_city IN (
    'rio de janeiro / rio de janeiro', 'rio de janeiro \rio de janeiro'
);
UPDATE sellers SET seller_city = 'belo horizonte' WHERE seller_city = 'belo horizont';
UPDATE sellers SET seller_city = 'angra dos reis' WHERE seller_city = 'angra dos reis rj';
UPDATE sellers SET seller_city = 'sao jose do rio preto' 
    WHERE seller_city IN ('sao jose do rio pret', 's jose do rio preto');
UPDATE sellers SET seller_city = 'mogi das cruzes' WHERE seller_city = 'mogi das cruzes / sp';
UPDATE sellers SET seller_city = 'pinhais' WHERE seller_city = 'pinhais/pr';
UPDATE sellers SET seller_city = 'unknown' WHERE seller_city = '04482255';
```

**Extra whitespace cleanup:**
```sql
UPDATE sellers SET seller_city = REGEXP_REPLACE(seller_city, '\s+', ' ', 'g');
UPDATE sellers SET seller_city = TRIM(seller_city);
```

### Issue 6.2 — Special Character Encoding in City Names

**Discovery:** Even after all text fixes, fuzzy matching still flagged `santa barbara d'oeste` appearing twice with 100% similarity score. Initial investigation showed both versions had identical character count (21) making it impossible to spot visually.

**Diagnosis:** Character-by-character ASCII code comparison revealed position 16 had different codes: `39` (standard apostrophe `'`) vs `180` (acute accent character `´`). This is a Unicode encoding inconsistency that would never be caught by visual inspection.

```sql
-- Diagnosis query
SELECT 
    seller_city,
    ASCII(SUBSTRING(seller_city, 16, 1)) as char_code_at_position_16
FROM sellers
WHERE seller_city LIKE '%barbara%'
GROUP BY seller_city;
-- Results: 39 and 180
```

```sql
-- Fix
UPDATE sellers SET seller_city = REPLACE(seller_city, chr(180), chr(39));
```

### Issue 6.3 — Referential Integrity

Checked that all foreign keys in child tables reference existing records in parent tables.

```sql
-- Example: orphaned records in order_items
SELECT COUNT(*) as orphaned_order_items
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
```

**Result:** Zero orphaned records across all relationships. Referential integrity is perfect.

### Issue 6.4 — Missing Category Translations

2 product categories existed in the products table but had no English translation:
- `portateis_cozinha_e_preparadores_de_alimentos` (10 products)
- `pc_gamer` (3 products)

```sql
INSERT INTO product_category_name_translation 
(product_category_name, product_category_name_english)
VALUES 
('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_and_food_processors'),
('pc_gamer', 'pc_gamer'),
('unknown', 'unknown');
```

---

## Tables 1–7 — Final Data Quality Summary

| Check | Status | Notes |
|---|---|---|
| Missing values — date columns | ✅ Fixed | 4,908 empty strings converted to NULL |
| Missing values — categories | ✅ Fixed | 610 empty strings set to 'unknown' |
| Missing values — review comments | ✅ Left | Legitimate customer behavior |
| Missing values — product dimensions | ✅ Left | Not used in analysis |
| Duplicate records | ✅ Clean | Zero duplicates in all tables |
| Data types — timestamps | ✅ Fixed | 8 columns converted from text to timestamp |
| Invalid values — date sequences | ✅ Flagged | 1,382 rows flagged, not deleted |
| Invalid values — installments | ✅ Fixed | 2 zero-installment payments set to 1 |
| City names — customers | ✅ Fixed | 8 inconsistencies resolved |
| City names — sellers | ✅ Fixed | 15+ inconsistencies resolved |
| Special characters — encoding | ✅ Fixed | ASCII chr(180) standardized to chr(39) |
| Referential integrity | ✅ Clean | Zero orphaned records |
| Category translations | ✅ Fixed | 3 missing translations added |

---

## Geolocation Table

### Structure

720,115 rows after cleaning (started at 1,000,163), 5 columns: `geolocation_zip_code_prefix` (integer), `geolocation_lat` / `geolocation_lng` (real), `geolocation_city` / `geolocation_state` (character varying). All 27 Brazilian states present, 19,011 unique zip prefixes, 5,966 unique cities.

**Important context:** This table is not a transaction log — it is a geographic reference table built by geocoding customer and seller addresses over time. The same zip prefix can appear many times with different coordinates (multiple delivery points within the same prefix). The appropriate analytical unit is one representative coordinate per unique zip+lat+lng+city+state combination, not one row per zip prefix.

### Step 2 — Missing Values

**Result: Clean.** Zero NULLs and zero empty strings across all five columns. Note: `lat`, `lng`, and `zip_code_prefix` are numeric types and cannot hold empty strings — missing values in numeric columns can only appear as NULL.

### Step 3 — Duplicates

**Finding:** 262,147 full-row duplicates existed before city name standardization, growing to 280,021 after accent normalization resolved what appeared to be distinct rows but were the same location under two spellings.

**Root cause:** The table was populated by logging one row per geocoding event. When many customers share the same zip prefix and the geocoder snaps them to the same coordinate, the identical row accumulates repeatedly. This is a structural artifact of how the table was built, not a data entry error.

**Decision: Fix** — Deduplicated to one row per unique (zip, lat, lng, city, state) combination. Repeated identical rows provide no additional geographic information and cause row-multiplication in any JOIN against customers or sellers.

**Important note on sequencing:** City name accent standardization (Step 6) was performed before deduplication so that rows differing only by accent would correctly collapse into single rows during the dedup step, avoiding the need to run deduplication twice.

**Method:** `ROW_NUMBER()` window function partitioned over all five columns — chosen over `NOT IN (SELECT MIN(ctid)...)` because the latter performs a full nested scan and becomes impractical at this scale (1M rows). The `ROW_NUMBER()` approach processes each partition in a single pass.

```sql
WITH ranked AS (
    SELECT ctid,
           ROW_NUMBER() OVER (
               PARTITION BY
                   geolocation_zip_code_prefix,
                   geolocation_lat,
                   geolocation_lng,
                   geolocation_city,
                   geolocation_state
               ORDER BY ctid
           ) AS rn
    FROM geolocation
)
DELETE FROM geolocation
WHERE ctid IN (
    SELECT ctid FROM ranked WHERE rn > 1
);
```

**Result:** 1,000,163 → 720,115 rows after full cleanup.

### Step 4 — Data Types

**Result: No changes needed.** `real` (32-bit float) for lat/lng provides ~7 significant digits of precision — approximately ±1 meter accuracy, more than sufficient for city-level delivery analysis. `double precision` would be unnecessary overhead across 720,000 rows for this use case.

### Step 5 — Invalid Values (Coordinate Outliers)

**Finding:** 27 rows had coordinates outside Brazil's geographic bounding box (lat: -33.75 to +5.27, lng: -73.99 to -28.85). Examples included Brazilian cities geocoded to the Philippines, Mexico, and Europe — classic geocoding API failures returning completely wrong locations.

**Decision: Delete** — Unlike the date sequence flags in the orders table (where transactions were real and complete), here the coordinate data itself is wrong. A Brazilian city plotted in the Philippines has no analytical value and would actively corrupt any map visualization or spatial join.

```sql
DELETE FROM geolocation
WHERE
    geolocation_lat < -33.75 OR geolocation_lat > 5.27
    OR geolocation_lng < -73.99 OR geolocation_lng > -28.85;
```

**Result:** 27 rows removed.

### Step 6 — Inconsistencies

**City name accent standardization:** 2,036 city names existed in both accented (`são paulo`) and unaccented (`sao paulo`) forms, affecting 472,718 rows total (73,439 rows were actually rewritten). Standardized to unaccented lowercase using PostgreSQL's `unaccent()` extension, consistent with the convention already applied to the customers and sellers tables.

**Investigation note:** Initial visual inspection of the raw data suggested an accent inconsistency, but a subsequent query using `unaccent()` returned zero results. Further investigation revealed the query had a logic bug (the inner HAVING clause was grouping by the raw column, not the normalized form). After fixing the query logic, the inconsistency was confirmed. This is a good example of why suspected findings should always be verified with a second query before acting on them.

```sql
CREATE EXTENSION IF NOT EXISTS unaccent;

UPDATE geolocation
SET geolocation_city = unaccent(geolocation_city)
WHERE geolocation_city <> unaccent(geolocation_city);
```

**City/state combinations:** 50+ city names appear under multiple states (e.g. `bom jesus` in GO, PB, PI, RN, RS, SC). **Decision: Leave** — These are genuinely distinct municipalities that share common names, a normal characteristic of Brazilian geography with 5,570 municipalities across 27 states. The state column correctly disambiguates them.

**State codes:** All 27 state codes verified as clean 2-letter abbreviations. No accent or formatting issues.

### Geolocation Final Quality Summary

| Check | Status | Notes |
|---|---|---|
| Missing values | ✅ Clean | Zero NULLs and empty strings |
| Full-row duplicates | ✅ Fixed | 280,021 redundant rows removed |
| Data types | ✅ Appropriate | real precision sufficient for use case |
| Coordinate outliers | ✅ Fixed | 27 rows outside Brazil's bounding box deleted |
| City name accents | ✅ Fixed | 73,439 rows standardized to unaccented form |
| City/state combinations | ✅ Left | Legitimate same-name municipalities in different states |
| State codes | ✅ Clean | All 27 valid Brazilian state abbreviations |

**Final row count:** 720,115  
**Unique zip prefixes:** 19,011  
**Coordinate range:** lat -33.69 to +4.48, lng -72.93 to -32.40 (fully within Brazil)

---

## Power BI Data Model Enhancement

**DAX Calculated Column — Geographic Context for Map Geocoding**

When loading the delivery_by_state data into Power BI, the 2-letter Brazilian state codes (e.g. `SP`, `RJ`) were ambiguous to the Bing Maps geocoding engine, which was misidentifying some as US states. A calculated column was added directly in the Power BI data model using DAX:

```
state_full = "Brazil, " & [customer_state]
```

This appends country context to each abbreviation (e.g. `SP` → `Brazil, SP`), ensuring correct geocoding on the map visuals. This demonstrates that data preparation is an iterative process — even after thorough SQL cleaning, additional transformations may be needed at the BI layer to support specific visualization requirements.

---

*Data cleaning completed: June–July 2026*  
*Tool used: PostgreSQL 16 via DBeaver 26.1.1*  
*Dataset: Olist Brazilian E-Commerce Public Dataset (Kaggle)*
