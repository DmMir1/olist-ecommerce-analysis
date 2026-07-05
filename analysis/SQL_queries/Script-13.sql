
SELECT 'orders' as table_name, COUNT(*) as rows FROM orders ood
UNION ALL
SELECT 'customers', COUNT(*) FROM customers ocd 
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items ooid 
UNION ALL
SELECT 'payments', COUNT(*) FROM order_payments oopd 
UNION ALL
SELECT 'reviews', COUNT(*) FROM order_reviews oord 
UNION ALL
SELECT 'products', COUNT(*) FROM products opd 
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers osd 
UNION ALL 
SELECT 'translations', COUNT(*) FROM product_category_name_translation pcnt; 

-- 1. How orders look like?
SELECT * FROM orders LIMIT 10;

-- 2. What order statuses do we have?
SELECT order_status, COUNT(*) as count
FROM orders
GROUP BY order_status
ORDER BY count DESC;

-- 3. Ower what time period was the data collected ?
SELECT 
    MIN(order_purchase_timestamp) as first_order,
    MAX(order_purchase_timestamp) as last_order
FROM orders;

-- Check for NULL values in orders table
SELECT
    COUNT(*) as total_rows,
    COUNT(order_id) as order_id_filled,
    COUNT(customer_id) as customer_id_filled,
    COUNT(order_approved_at) as approved_filled,
    COUNT(order_delivered_carrier_date) as carrier_filled,
    COUNT(order_delivered_customer_date) as customer_delivered_filled
FROM orders;

-- Check NULLs more carefully
SELECT
    COUNT(*) as total_rows,
    COUNT(*) - COUNT(order_approved_at) as missing_approved,
    COUNT(*) - COUNT(order_delivered_carrier_date) as missing_carrier_date,
    COUNT(*) - COUNT(order_delivered_customer_date) as missing_delivery_date,
    COUNT(*) - COUNT(order_estimated_delivery_date) as missing_estimated_date
FROM orders;

-- Check if empty strings exist instead of NULLs
SELECT COUNT(*) as empty_delivery_dates
FROM orders
WHERE order_delivered_customer_date = '';


-- Check ALL columns in orders for empty strings
SELECT 
    'order_id' as column_name, COUNT(*) as empty_count FROM orders WHERE order_id = '' UNION ALL
    SELECT 'customer_id', COUNT(*) FROM orders WHERE customer_id = '' UNION ALL
    SELECT 'order_status', COUNT(*) FROM orders WHERE order_status = '' UNION ALL
    SELECT 'order_purchase_timestamp', COUNT(*) FROM orders WHERE order_purchase_timestamp = '' UNION ALL
    SELECT 'order_approved_at', COUNT(*) FROM orders WHERE order_approved_at = '' UNION ALL
    SELECT 'order_delivered_carrier_date', COUNT(*) FROM orders WHERE order_delivered_carrier_date = '' UNION ALL
    SELECT 'order_delivered_customer_date', COUNT(*) FROM orders WHERE order_delivered_customer_date = '' UNION ALL
    SELECT 'order_estimated_delivery_date', COUNT(*) FROM orders WHERE order_estimated_delivery_date = '';

-- Check ALL columns in products (mix of text and numeric)

SELECT 'product_id' as column_name, COUNT(*) as empty_count FROM products WHERE product_id = '' UNION ALL
SELECT 'product_category_name', COUNT(*) FROM products WHERE product_category_name = '' UNION ALL
SELECT 'product_name_lenght (NULL check)', COUNT(*) FROM products WHERE product_name_lenght IS NULL UNION ALL
SELECT 'product_description_lenght (NULL check)', COUNT(*) FROM products WHERE product_description_lenght IS NULL UNION ALL
SELECT 'product_weight_g (NULL check)', COUNT(*) FROM products WHERE product_weight_g IS NULL;

-- Check customers
SELECT 'customer_id' as column_name, COUNT(*) as empty_count FROM customers WHERE customer_id = '' UNION ALL
SELECT 'customer_unique_id', COUNT(*) FROM customers WHERE customer_unique_id = '' UNION ALL
SELECT 'customer_city', COUNT(*) FROM customers WHERE customer_city = '' UNION ALL
SELECT 'customer_state', COUNT(*) FROM customers WHERE customer_state = '';

-- Check order_items
SELECT 'order_id' as column_name, COUNT(*) as empty_count FROM order_items WHERE order_id = '' UNION ALL
SELECT 'product_id', COUNT(*) FROM order_items WHERE product_id = '' UNION ALL
SELECT 'seller_id', COUNT(*) FROM order_items WHERE seller_id = '' UNION ALL
SELECT 'shipping_limit_date', COUNT(*) FROM order_items WHERE shipping_limit_date = '';

-- Check order_payments
SELECT 'order_id' as column_name, COUNT(*) as empty_count FROM order_payments WHERE order_id = '' UNION ALL
SELECT 'payment_type', COUNT(*) FROM order_payments WHERE payment_type = '';

-- Check sellers
SELECT 'seller_id' as column_name, COUNT(*) as empty_count FROM sellers WHERE seller_id = '' UNION ALL
SELECT 'seller_city', COUNT(*) FROM sellers WHERE seller_city = '' UNION ALL
SELECT 'seller_state', COUNT(*) FROM sellers WHERE seller_state = '';

-- Check order_reviews
SELECT 'order_id' as column_name, COUNT(*) as empty_count FROM order_reviews WHERE order_id = '' UNION ALL
SELECT 'review_comment_title', COUNT(*) FROM order_reviews WHERE review_comment_title = '' UNION ALL
SELECT 'review_comment_message', COUNT(*) FROM order_reviews WHERE review_comment_message = '';

-- Fix orders: convert empty strings to NULL
UPDATE orders SET order_approved_at = NULL 
WHERE order_approved_at = '';

UPDATE orders SET order_delivered_carrier_date = NULL 
WHERE order_delivered_carrier_date = '';

UPDATE orders SET order_delivered_customer_date = NULL 
WHERE order_delivered_customer_date = '';

UPDATE products SET product_category_name = 'unknown'
WHERE product_category_name = '';

-- 1. Duplicates in orders
SELECT order_id, COUNT(*) as count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 2. Duplicates in customers
SELECT customer_id, COUNT(*) as count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 3. Duplicates in products
SELECT product_id, COUNT(*) as count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- 4. Duplicates in sellers
SELECT seller_id, COUNT(*) as count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

-- 5. Duplicates in order_items (composite key)
SELECT order_id, order_item_id, COUNT(*) as count
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- 6. Duplicates in order_payments (composite key)
SELECT order_id, payment_sequential, COUNT(*) as count
FROM order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

-- Check data types for orders table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'orders'
ORDER BY ordinal_position;

-- Check data types for order_items table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'order_items'
ORDER BY ordinal_position;

-- Check data types for order_payments table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'order_payments'
ORDER BY ordinal_position;

-- Check data types for products table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'products'
ORDER BY ordinal_position;

-- Check data types for customers table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'customers'
ORDER BY ordinal_position;

-- Check data types for sellers table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'sellers'
ORDER BY ordinal_position;

-- Check data types for order_reviews table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'order_reviews'
ORDER BY ordinal_position;

-- Fix orders date columns
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

-- Fix order_reviews date columns
ALTER TABLE order_reviews
    ALTER COLUMN review_creation_date TYPE timestamp 
        USING review_creation_date::timestamp,
    ALTER COLUMN review_answer_timestamp TYPE timestamp 
        USING review_answer_timestamp::timestamp;

-- Fix order_items date column
ALTER TABLE order_items
    ALTER COLUMN shipping_limit_date TYPE timestamp 
        USING shipping_limit_date::timestamp;

-- Verify orders dates are now timestamps
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'orders'
ORDER BY ordinal_position;

-- 1. Delivery date BEFORE purchase date (impossible)
SELECT COUNT(*) as impossible_deliveries
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

-- 2. Approval date BEFORE purchase date (impossible)
SELECT COUNT(*) as impossible_approvals
FROM orders
WHERE order_approved_at < order_purchase_timestamp;

-- 3. Carrier pickup BEFORE approval (impossible)
SELECT COUNT(*) as impossible_carrier_pickup
FROM orders
WHERE order_delivered_carrier_date < order_approved_at;

-- 4. Customer delivery BEFORE carrier pickup (impossible)
SELECT COUNT(*) as impossible_sequence
FROM orders
WHERE order_delivered_customer_date < order_delivered_carrier_date;

-- 5. Estimated delivery BEFORE purchase date (impossible)
SELECT COUNT(*) as impossible_estimates
FROM orders
WHERE order_estimated_delivery_date < order_purchase_timestamp;

-- 6. Negative or zero prices in order_items
SELECT COUNT(*) as invalid_prices
FROM order_items
WHERE price <= 0;

-- 7. Negative freight values
SELECT COUNT(*) as invalid_freight
FROM order_items
WHERE freight_value < 0;

-- 8. Review score outside 1-5 range
SELECT COUNT(*) as invalid_scores
FROM order_reviews
WHERE review_score < 1 OR review_score > 5;

-- 9. Negative payment values
SELECT COUNT(*) as invalid_payments
FROM order_payments
WHERE payment_value < 0;

-- 10. Payment installments less than 1
SELECT COUNT(*) as invalid_installments
FROM order_payments
WHERE payment_installments < 1;

-- Investigate carrier pickup before approval
SELECT 
    order_id,
    order_status,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_carrier_date - order_approved_at as time_difference
FROM orders
WHERE order_delivered_carrier_date < order_approved_at
ORDER BY time_difference
LIMIT 20;

-- Investigate delivery before carrier pickup
SELECT
    order_id,
    order_status,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_delivered_customer_date - order_delivered_carrier_date as time_difference
FROM orders
WHERE order_delivered_customer_date < order_delivered_carrier_date
ORDER BY time_difference
LIMIT 20;


-- Investigate invalid installments
SELECT *
FROM order_payments
WHERE payment_installments < 1;

-- Flag orders with suspicious date sequences
ALTER TABLE orders ADD COLUMN is_date_sequence_valid boolean;

UPDATE orders SET is_date_sequence_valid = 
    CASE 
        WHEN order_delivered_carrier_date < order_approved_at THEN false
        WHEN order_delivered_customer_date < order_delivered_carrier_date THEN false
        ELSE true
    END;

-- Verify the flag
SELECT is_date_sequence_valid, COUNT(*) 
FROM orders 
GROUP BY is_date_sequence_valid;

-- Fix zero installments
UPDATE order_payments 
SET payment_installments = 1
WHERE payment_installments < 1;

-- 1. Check city name inconsistencies in customers
-- Are there same cities written differently?
SELECT customer_city, COUNT(*) as count
FROM customers
GROUP BY customer_city
ORDER BY customer_city
LIMIT 30;

-- Find cities with unusual characters or mixed case
SELECT DISTINCT customer_city
FROM customers
WHERE customer_city != LOWER(customer_city);

-- Find cities with numbers (like our ZIP code issue in sellers)
SELECT DISTINCT customer_city
FROM customers
WHERE customer_city ~ '[0-9]';

-- Cities with only 1 customer are suspicious
-- they might be misspellings of larger cities
SELECT customer_city, COUNT(*) as count
FROM customers
GROUP BY customer_city
HAVING COUNT(*) = 1
ORDER BY customer_city
LIMIT 30;

-- Find city names that are very similar to each other
-- using trigram similarity (requires pg_trgm extension)
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
ORDER BY similarity_score DESC
LIMIT 30;

-- Check counts for all suspicious pairs
SELECT customer_city, COUNT(*) as customer_count
FROM customers
WHERE customer_city IN (
    'pires do rio', 'rio do pires',
    'brasil novo', 'novo brasil',
    'belo campo', 'campo belo',
    'santa barbara d''oe', 'santa barbara d oe',
    'mogi-mirim', 'mogi mirim',
    'estrela d''oeste', 'estrela d oeste',
    'nova ponte', 'ponte nova',
    'guara', 'guarara',
    'sao jorge d''oeste', 'sao jorge do oeste',
    'itapetinga', 'itapetininga'
)
GROUP BY customer_city
ORDER BY customer_city;

-- Fuzzy matching on sellers
SELECT 
    a.seller_city as city_1,
    b.seller_city as city_2,
    similarity(a.seller_city, b.seller_city) as similarity_score
FROM 
    (SELECT DISTINCT seller_city FROM sellers) a,
    (SELECT DISTINCT seller_city FROM sellers) b
WHERE 
    a.seller_city < b.seller_city
    AND similarity(a.seller_city, b.seller_city) > 0.8
ORDER BY similarity_score DESC
LIMIT 30;

-- 2. Check city name inconsistencies in sellers
SELECT seller_city, COUNT(*) as count
FROM sellers
GROUP BY seller_city
ORDER BY seller_city
LIMIT 30;

-- 3. Orphaned records in order_items
-- Do all order_ids in order_items exist in orders?
SELECT COUNT(*) as orphaned_order_items
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 4. Orphaned records in order_payments
-- Do all order_ids in payments exist in orders?
SELECT COUNT(*) as orphaned_payments
FROM order_payments op
LEFT JOIN orders o ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 5. Orphaned records in order_reviews
-- Do all order_ids in reviews exist in orders?
SELECT COUNT(*) as orphaned_reviews
FROM order_reviews orv
LEFT JOIN orders o ON orv.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 6. Check if all products in order_items exist in products table
SELECT COUNT(*) as missing_products
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 7. Check if all sellers in order_items exist in sellers table
SELECT COUNT(*) as missing_sellers
FROM order_items oi
LEFT JOIN sellers s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- 8. Check product categories consistency with translation table
-- Are there categories in products that have no translation?
SELECT p.product_category_name, COUNT(*) as count
FROM products p
LEFT JOIN product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL
GROUP BY p.product_category_name
ORDER BY count DESC;

-- 9. Check state codes are valid (should be 2 letter Brazilian state codes)
SELECT customer_state, COUNT(*) as count
FROM customers
GROUP BY customer_state
ORDER BY count DESC;

-- Check counts for all suspicious pairs
SELECT customer_city, COUNT(*) as customer_count
FROM customers
WHERE customer_city IN (
    'pires do rio', 'rio do pires',
    'brasil novo', 'novo brasil',
    'belo campo', 'campo belo',
    'santa barbara d''oe', 'santa barbara d oe',
    'mogi-mirim', 'mogi mirim',
    'estrela d''oeste', 'estrela d oeste',
    'nova ponte', 'ponte nova',
    'guara', 'guarara',
    'sao jorge d''oeste', 'sao jorge do oeste',
    'itapetinga', 'itapetininga'
)
GROUP BY customer_city
ORDER BY customer_city;

-- Fix customers
UPDATE customers SET customer_city = 'campo belo' WHERE customer_city = 'belo campo';
UPDATE customers SET customer_city = 'mogi mirim' WHERE customer_city = 'mogi-mirim';
UPDATE customers SET customer_city = 'pires do rio' WHERE customer_city = 'rio do pires';
UPDATE customers SET customer_city = 'estrela d''oeste' WHERE customer_city = 'estrela d oeste';
UPDATE customers SET customer_city = 'sao jorge do oeste' WHERE customer_city = 'sao jorge d''oeste';

-- Fix sellers - sao paulo variations
UPDATE sellers SET seller_city = 'sao paulo' WHERE seller_city IN (
    'sao paulo sp',
    'sao paulo - sp',
    'sao paulo / sao paulo',
    'sao paulo sp',
    'sao  paulo',
    'sp / sp'
);

-- Fix rio de janeiro variations
UPDATE sellers SET seller_city = 'rio de janeiro' WHERE seller_city IN (
    'rio de janeiro / rio de janeiro',
    'rio de janeiro \rio de janeiro'
);

-- Fix other seller cities
UPDATE sellers SET seller_city = 'santa barbara d''oeste' 
    WHERE seller_city = 'santa barbara d oeste';
UPDATE sellers SET seller_city = 'ferraz de vasconcelos' 
    WHERE seller_city = 'ferraz de vasconcelos';
UPDATE sellers SET seller_city = 'belo horizonte' 
    WHERE seller_city = 'belo horizont';
UPDATE sellers SET seller_city = 'angra dos reis' 
    WHERE seller_city = 'angra dos reis rj';
UPDATE sellers SET seller_city = 'sao jose do rio preto' 
    WHERE seller_city IN ('sao jose do rio pret', 's jose do rio preto');
UPDATE sellers SET seller_city = 'sao paulo' 
    WHERE seller_city = 'sao paulo - sp';

-- Verify customers are clean
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
ORDER BY similarity_score DESC
LIMIT 20;

-- Verify sellers are clean
SELECT 
    a.seller_city as city_1,
    b.seller_city as city_2,
    similarity(a.seller_city, b.seller_city) as similarity_score
FROM 
    (SELECT DISTINCT seller_city FROM sellers) a,
    (SELECT DISTINCT seller_city FROM sellers) b
WHERE 
    a.seller_city < b.seller_city
    AND similarity(a.seller_city, b.seller_city) > 0.8
ORDER BY similarity_score DESC
LIMIT 20;

-- Fix remaining customers
UPDATE customers SET customer_city = 'palmeira d''oeste' 
    WHERE customer_city = 'palmeira d oeste';
UPDATE customers SET customer_city = 'dias d''avila' 
    WHERE customer_city = 'dias d avila';
UPDATE customers SET customer_city = 'arraial d''ajuda' 
    WHERE customer_city = 'arraial d ajuda';
UPDATE customers SET customer_city = 'santa barbara d''oeste' 
    WHERE customer_city = 'santa barbara d oe';

-- Fix remaining sellers
UPDATE sellers SET seller_city = 'sao jose dos pinhais' 
    WHERE seller_city = 'sao jose dos pinhais';
UPDATE sellers SET seller_city = 'sao paulo' 
    WHERE seller_city IN ('sp / sp', 'sao paulo / sao paulo', 'sao paulo sp', 'sao  paulo');
UPDATE sellers SET seller_city = 'santa barbara d''oeste' 
    WHERE seller_city = 'santa barbara d oeste';
UPDATE sellers SET seller_city = 'ferraz de vasconcelos' 
    WHERE seller_city = 'ferraz de vasconcelos';
UPDATE sellers SET seller_city = 'sao miguel do oeste' 
    WHERE seller_city = 'sao miguel d''oeste';
UPDATE sellers SET seller_city = 'mogi das cruzes' 
    WHERE seller_city = 'mogi das cruzes / sp';
UPDATE sellers SET seller_city = 'pinhais' 
    WHERE seller_city = 'pinhais/pr';

-- Final verification customers
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
ORDER BY similarity_score DESC
LIMIT 20;

-- Final verification sellers
SELECT 
    a.seller_city as city_1,
    b.seller_city as city_2,
    similarity(a.seller_city, b.seller_city) as similarity_score
FROM 
    (SELECT DISTINCT seller_city FROM sellers) a,
    (SELECT DISTINCT seller_city FROM sellers) b
WHERE 
    a.seller_city < b.seller_city
    AND similarity(a.seller_city, b.seller_city) > 0.8
ORDER BY similarity_score DESC
LIMIT 20;

-- Fix remaining customers
UPDATE customers SET customer_city = 'santa barbara d''oeste'
WHERE customer_city = 'santa barbara d oe';

-- Fix extra spaces in sellers using TRIM and REGEXP_REPLACE
UPDATE sellers SET seller_city = REGEXP_REPLACE(seller_city, '\s+', ' ', 'g');
UPDATE sellers SET seller_city = TRIM(seller_city);

-- Final verification customers
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
ORDER BY similarity_score DESC
LIMIT 20;

-- Final verification sellers
SELECT 
    a.seller_city as city_1,
    b.seller_city as city_2,
    similarity(a.seller_city, b.seller_city) as similarity_score
FROM 
    (SELECT DISTINCT seller_city FROM sellers) a,
    (SELECT DISTINCT seller_city FROM sellers) b
WHERE 
    a.seller_city < b.seller_city
    AND similarity(a.seller_city, b.seller_city) > 0.8
ORDER BY similarity_score DESC
LIMIT 20;

-- Find the exact versions
SELECT DISTINCT seller_city, LENGTH(seller_city) as char_length
FROM sellers
WHERE seller_city LIKE '%barbara%'
ORDER BY char_length;

-- Standardize all apostrophes in seller_city - simplified approach
UPDATE sellers 
SET seller_city = REPLACE(seller_city, chr(8217), chr(39));

-- Also fix curly opening apostrophe just in case
UPDATE sellers 
SET seller_city = REPLACE(seller_city, chr(8216), chr(39));

-- Verify fix worked
SELECT DISTINCT seller_city, LENGTH(seller_city) as char_length
FROM sellers
WHERE seller_city LIKE '%barbara%'
ORDER BY char_length;

-- Find the exact ASCII code of the apostrophe character in each version
SELECT 
    seller_city,
    ASCII(SUBSTRING(seller_city, 15, 1)) as char_code_at_position_15
FROM sellers
WHERE seller_city LIKE '%barbara%'
GROUP BY seller_city;

-- Compare character by character
SELECT 
    seller_city,
    ASCII(SUBSTRING(seller_city, 13, 1)) as pos_13,
    ASCII(SUBSTRING(seller_city, 14, 1)) as pos_14,
    ASCII(SUBSTRING(seller_city, 15, 1)) as pos_15,
    ASCII(SUBSTRING(seller_city, 16, 1)) as pos_16,
    ASCII(SUBSTRING(seller_city, 17, 1)) as pos_17,
    ASCII(SUBSTRING(seller_city, 18, 1)) as pos_18,
    ASCII(SUBSTRING(seller_city, 19, 1)) as pos_19,
    ASCII(SUBSTRING(seller_city, 20, 1)) as pos_20,
    ASCII(SUBSTRING(seller_city, 21, 1)) as pos_21
FROM sellers
WHERE seller_city LIKE '%barbara%'
GROUP BY seller_city;

-- Fix acute accent character (180) to standard apostrophe (39)
UPDATE sellers 
SET seller_city = REPLACE(seller_city, chr(180), chr(39));

-- Verify fix worked
SELECT DISTINCT seller_city, LENGTH(seller_city) as char_length
FROM sellers
WHERE seller_city LIKE '%barbara%'
ORDER BY char_length;

-- Final final verification sellers
SELECT 
    a.seller_city as city_1,
    b.seller_city as city_2,
    similarity(a.seller_city, b.seller_city) as similarity_score
FROM 
    (SELECT DISTINCT seller_city FROM sellers) a,
    (SELECT DISTINCT seller_city FROM sellers) b
WHERE 
    a.seller_city < b.seller_city
    AND similarity(a.seller_city, b.seller_city) > 0.8
ORDER BY similarity_score DESC
LIMIT 20;

-- Row count and basic structure for geolocation table
SELECT COUNT(*) AS total_rows
FROM geolocation;

-- Column info: names, types, nullability
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'geolocation'
ORDER BY ordinal_position;

-- Quick peek at actual data
SELECT *
FROM geolocation
LIMIT 10;

-- Step 2: Missing values — true NULLs
SELECT
    COUNT(*) FILTER (WHERE geolocation_zip_code_prefix IS NULL) AS null_zip,
    COUNT(*) FILTER (WHERE geolocation_lat IS NULL) AS null_lat,
    COUNT(*) FILTER (WHERE geolocation_lng IS NULL) AS null_lng,
    COUNT(*) FILTER (WHERE geolocation_city IS NULL) AS null_city,
    COUNT(*) FILTER (WHERE geolocation_state IS NULL) AS null_state
FROM geolocation;

-- Step 2: Missing values — empty strings (only applies to text columns)
SELECT
    COUNT(*) FILTER (WHERE geolocation_city = '') AS empty_city,
    COUNT(*) FILTER (WHERE geolocation_state = '') AS empty_state
FROM geolocation;

-- Step 3: Full-row duplicates
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS occurrences
FROM geolocation
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- Same thing, but just get the total count of duplicate rows for a quick summary
SELECT SUM(occurrences - 1) AS total_redundant_rows
FROM (
    SELECT COUNT(*) AS occurrences
    FROM geolocation
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state
    HAVING COUNT(*) > 1
) dupes;

-- Does each duplicate group always share the same zip/city/state (sanity check —
-- making sure these aren't actually different things that happen to collide)
SELECT geolocation_zip_code_prefix, COUNT(DISTINCT geolocation_city) AS distinct_cities_for_this_exact_point
FROM geolocation
GROUP BY geolocation_zip_code_prefix, geolocation_lat, geolocation_lng
HAVING COUNT(*) > 1 AND COUNT(DISTINCT geolocation_city) > 1;

-- How would the table's "shape" change if we deduplicated fully?
-- i.e. how many unique zip-prefix-to-coordinate mappings actually exist
SELECT COUNT(*) AS unique_rows_after_dedup
FROM (
    SELECT DISTINCT
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state
    FROM geolocation
) t;

CREATE EXTENSION IF NOT EXISTS unaccent;

-- Find city names that are identical except for accents (most likely error type here)
SELECT
    geolocation_city,
    unaccent(geolocation_city) AS normalized,
    COUNT(*) AS row_count
FROM geolocation
GROUP BY geolocation_city
HAVING unaccent(geolocation_city) IN (
    SELECT unaccent(geolocation_city)
    FROM geolocation
    GROUP BY geolocation_city
    HAVING COUNT(DISTINCT geolocation_city) > 1
)
ORDER BY normalized, geolocation_city;

-- Confirm the extension is actually installed and unaccent works
SELECT unaccent('são paulo') AS test;

-- Direct proof: search specifically for any city containing the literal "ã" character
SELECT DISTINCT geolocation_city
FROM geolocation
WHERE geolocation_city LIKE '%ã%' OR geolocation_city LIKE '%á%' OR geolocation_city LIKE '%é%'
   OR geolocation_city LIKE '%í%' OR geolocation_city LIKE '%ó%' OR geolocation_city LIKE '%ú%'
   OR geolocation_city LIKE '%ç%' OR geolocation_city LIKE '%â%' OR geolocation_city LIKE '%ê%';

-- Corrected: find normalized (unaccented) city names that map to more than one distinct raw spelling
SELECT
    unaccent(geolocation_city) AS normalized,
    COUNT(DISTINCT geolocation_city) AS spelling_variants,
    STRING_AGG(DISTINCT geolocation_city, ' | ') AS variants_list,
    COUNT(*) AS total_rows
FROM geolocation
GROUP BY unaccent(geolocation_city)
HAVING COUNT(DISTINCT geolocation_city) > 1
ORDER BY total_rows DESC;

-- Total scope: how many rows are affected by this accent-spelling split, and how many distinct place names
SELECT
    COUNT(*) AS distinct_places_affected,
    SUM(total_rows) AS total_rows_affected
FROM (
    SELECT unaccent(geolocation_city) AS normalized, COUNT(*) AS total_rows
    FROM geolocation
    GROUP BY unaccent(geolocation_city)
    HAVING COUNT(DISTINCT geolocation_city) > 1
) sub;

-- Quick check: does state have any accent issues (low expectation, but verify)
SELECT DISTINCT geolocation_state FROM geolocation ORDER BY geolocation_state;

-- Fix: standardize all city names to unaccented form, matching customers/sellers convention
UPDATE geolocation
SET geolocation_city = unaccent(geolocation_city)
WHERE geolocation_city <> unaccent(geolocation_city);

-- Verify: should now return zero rows (no more accent-based spelling splits)
SELECT unaccent(geolocation_city) AS normalized, COUNT(DISTINCT geolocation_city) AS variants
FROM geolocation
GROUP BY unaccent(geolocation_city)
HAVING COUNT(DISTINCT geolocation_city) > 1;

-- Re-check full-row duplicate count now that city names are standardized
SELECT SUM(occurrences - 1) AS total_redundant_rows
FROM (
    SELECT COUNT(*) AS occurrences
    FROM geolocation
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state
    HAVING COUNT(*) > 1
) dupes;

-- Step 3 fix: delete full-row duplicates, keeping one row per unique combination
DELETE FROM geolocation
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM geolocation
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state
);

-- Faster deduplication using ROW_NUMBER()
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

-- Verify: confirm new row count (should be 1,000,163 - 280,021 = 720,142)
SELECT COUNT(*) AS rows_after_dedup FROM geolocation;

-- Step 5: coordinates outside Brazil's bounding box
SELECT
    COUNT(*) FILTER (WHERE geolocation_lat < -33.75 OR geolocation_lat > 5.27) AS invalid_lat,
    COUNT(*) FILTER (WHERE geolocation_lng < -73.99 OR geolocation_lng > -28.85) AS invalid_lng,
    COUNT(*) FILTER (WHERE
        geolocation_lat < -33.75 OR geolocation_lat > 5.27
        OR geolocation_lng < -73.99 OR geolocation_lng > -28.85
    ) AS invalid_either
FROM geolocation;

-- See the actual outlier rows so we know what we're dealing with
SELECT *
FROM geolocation
WHERE
    geolocation_lat < -33.75 OR geolocation_lat > 5.27
    OR geolocation_lng < -73.99 OR geolocation_lng > -28.85
ORDER BY geolocation_lat
LIMIT 50;

-- Step 5 fix: delete rows with coordinates outside Brazil's bounding box
DELETE FROM geolocation
WHERE
    geolocation_lat < -33.75 OR geolocation_lat > 5.27
    OR geolocation_lng < -73.99 OR geolocation_lng > -28.85;

-- Verify: should be 720,142 - 27 = 720,115
SELECT COUNT(*) AS rows_after_coordinate_cleanup FROM geolocation;

-- Step 6: cities appearing under more than one state
SELECT
    geolocation_city,
    COUNT(DISTINCT geolocation_state) AS state_count,
    STRING_AGG(DISTINCT geolocation_state, ', ' ORDER BY geolocation_state) AS states
FROM geolocation
GROUP BY geolocation_city
HAVING COUNT(DISTINCT geolocation_state) > 1
ORDER BY state_count DESC, geolocation_city
LIMIT 50;

-- Final state of the geolocation table
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT geolocation_zip_code_prefix) AS unique_zip_prefixes,
    COUNT(DISTINCT geolocation_city) AS unique_cities,
    COUNT(DISTINCT geolocation_state) AS unique_states,
    ROUND(MIN(geolocation_lat)::numeric, 4) AS min_lat,
    ROUND(MAX(geolocation_lat)::numeric, 4) AS max_lat,
    ROUND(MIN(geolocation_lng)::numeric, 4) AS min_lng,
    ROUND(MAX(geolocation_lng)::numeric, 4) AS max_lng
FROM geolocation;

-- What time period does the dataset cover, and how many orders per month?
SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS month,
    COUNT(*) AS orders,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY month;

-- Monthly revenue trend with month-over-month growth rate
-- Clean window: Oct 2016 - Aug 2018
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
        COUNT(DISTINCT o.order_id) AS orders,
        COUNT(oi.order_item_id) AS items_sold,
        ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue,
        ROUND(AVG(oi.price + oi.freight_value)::numeric, 2) AS avg_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
        AND o.order_purchase_timestamp >= '2016-10-01'
        AND o.order_purchase_timestamp < '2018-09-01'
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
)
SELECT
    month,
    orders,
    items_sold,
    revenue,
    avg_order_value,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0)
    , 1) AS revenue_mom_pct  -- month over month growth %
FROM monthly
ORDER BY month;

-- True average order value (per order, not per item)
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
        COUNT(DISTINCT o.order_id) AS orders,
        ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
        AND o.order_purchase_timestamp >= '2016-10-01'
        AND o.order_purchase_timestamp < '2018-09-01'
        AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
)
SELECT
    month,
    orders,
    revenue,
    ROUND(revenue / orders, 2) AS avg_order_value_true
FROM monthly
ORDER BY month;

-- Revenue by product category (full period, ranked)
SELECT
    COALESCE(t.product_category_name_english, 'unknown') AS category,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue,
    ROUND(100.0 * SUM(oi.price + oi.freight_value)::numeric
        / SUM(SUM(oi.price + oi.freight_value)::numeric) OVER ()
    , 2) AS revenue_pct,
    ROUND(AVG(oi.price)::numeric, 2) AS avg_item_price
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status NOT IN ('canceled', 'unavailable')
    AND o.order_purchase_timestamp >= '2016-10-01'
    AND o.order_purchase_timestamp < '2018-09-01'
    AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
GROUP BY COALESCE(t.product_category_name_english, 'unknown')
ORDER BY revenue DESC;

-- Delivery performance overview: on-time vs late, and average delivery times
SELECT
    COUNT(*) AS delivered_orders,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp))
        / 86400
    )::numeric, 1) AS avg_days_to_deliver,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (order_estimated_delivery_date - order_purchase_timestamp))
        / 86400
    )::numeric, 1) AS avg_days_promised,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (order_estimated_delivery_date - order_delivered_customer_date))
        / 86400
    )::numeric, 1) AS avg_days_early_late, -- positive = early, negative = late
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date > order_estimated_delivery_date
    ) AS late_deliveries,
    ROUND(100.0 * COUNT(*) FILTER (
        WHERE order_delivered_customer_date > order_estimated_delivery_date
    ) / COUNT(*)::numeric, 1) AS late_pct
FROM orders
WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL
    AND is_date_sequence_valid = true  -- exclude the 1,382 flagged rows
    AND order_purchase_timestamp >= '2016-10-01'
    AND order_purchase_timestamp < '2018-09-01'
    AND DATE_TRUNC('month', order_purchase_timestamp) <> '2016-12-01';

-- Delivery performance by customer state
SELECT
    c.customer_state,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp))
        / 86400
    )::numeric, 1) AS avg_days_to_deliver,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (o.order_estimated_delivery_date - o.order_delivered_customer_date))
        / 86400
    )::numeric, 1) AS avg_days_early_late,
    COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
    ) AS late_deliveries,
    ROUND(100.0 * COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
    ) / COUNT(*)::numeric, 1) AS late_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
    AND o.is_date_sequence_valid = true
    AND o.order_purchase_timestamp >= '2016-10-01'
    AND o.order_purchase_timestamp < '2018-09-01'
    AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
GROUP BY c.customer_state
ORDER BY avg_days_to_deliver DESC;

-- RFM Analysis: Recency, Frequency, Monetary per customer
-- Reference date: day after the last order in our clean window
WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS monetary
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
        AND o.order_purchase_timestamp >= '2016-10-01'
        AND o.order_purchase_timestamp < '2018-09-01'
        AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
    GROUP BY c.customer_unique_id
),
rfm_scored AS (
    SELECT
        customer_unique_id,
        last_order_date,
        frequency,
        monetary,
        EXTRACT(DAY FROM (TIMESTAMP '2018-09-01' - last_order_date))::int AS recency_days,
        NTILE(5) OVER (ORDER BY last_order_date DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC, monetary ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)
SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    r_score + f_score + m_score AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 THEN 'Champion'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal'
        WHEN r_score >= 4 AND f_score < 3 THEN 'Recent'
        WHEN r_score < 3 AND f_score >= 3 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
        ELSE 'Potential'
    END AS segment
FROM rfm_scored
ORDER BY rfm_total DESC;

-- RFM segment summary: the business view
WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS monetary
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
        AND o.order_purchase_timestamp >= '2016-10-01'
        AND o.order_purchase_timestamp < '2018-09-01'
        AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
    GROUP BY c.customer_unique_id
),
rfm_scored AS (
    SELECT
        customer_unique_id,
        frequency,
        monetary,
        EXTRACT(DAY FROM (TIMESTAMP '2018-09-01' - last_order_date))::int AS recency_days,
        NTILE(5) OVER (ORDER BY last_order_date DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC, monetary ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
),
rfm_segmented AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        monetary,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 THEN 'Champion'
            WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal'
            WHEN r_score >= 4 AND f_score < 3 THEN 'Recent'
            WHEN r_score < 3 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
            ELSE 'Potential'
        END AS segment
    FROM rfm_scored
)
SELECT
    segment,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()::numeric, 1) AS pct_of_customers,
    ROUND(AVG(monetary)::numeric, 2) AS avg_monetary,
    ROUND(SUM(monetary)::numeric, 2) AS total_revenue,
    ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER ()::numeric, 1) AS pct_of_revenue,
    ROUND(AVG(frequency)::numeric, 2) AS avg_orders,
    ROUND(AVG(recency_days)::numeric, 0) AS avg_recency_days
FROM rfm_segmented
GROUP BY segment
ORDER BY total_revenue DESC;

-- Frequency distribution: what % of customers bought more than once?
SELECT
    frequency,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()::numeric, 1) AS pct
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS frequency
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
        AND o.order_purchase_timestamp >= '2016-10-01'
        AND o.order_purchase_timestamp < '2018-09-01'
        AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
    GROUP BY c.customer_unique_id
) freq_dist
GROUP BY frequency
ORDER BY frequency;

-- Seller performance: revenue, delivery, and review scores
SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue,
    ROUND(AVG(oi.price)::numeric, 2) AS avg_item_price,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp))
        / 86400
    )::numeric, 1) AS avg_days_to_deliver,
    ROUND(100.0 * COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
    ) / COUNT(*)::numeric, 1) AS late_pct,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score,
    COUNT(DISTINCT r.review_id) AS reviews_received
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
    AND o.order_purchase_timestamp >= '2016-10-01'
    AND o.order_purchase_timestamp < '2018-09-01'
    AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.is_date_sequence_valid = true
GROUP BY s.seller_id, s.seller_city, s.seller_state
HAVING COUNT(DISTINCT o.order_id) >= 10  -- exclude micro-sellers, statistically unreliable
ORDER BY revenue DESC;

-- Seller performance quadrants
WITH seller_stats AS (
    SELECT
        s.seller_id,
        s.seller_city,
        s.seller_state,
        COUNT(DISTINCT o.order_id) AS orders,
        ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue,
        ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score,
        ROUND(100.0 * COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
        ) / COUNT(*)::numeric, 1) AS late_pct
    FROM sellers s
    JOIN order_items oi ON s.seller_id = oi.seller_id
    JOIN orders o ON oi.order_id = o.order_id
    LEFT JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
        AND o.order_purchase_timestamp >= '2016-10-01'
        AND o.order_purchase_timestamp < '2018-09-01'
        AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
        AND o.order_delivered_customer_date IS NOT NULL
        AND o.is_date_sequence_valid = true
    GROUP BY s.seller_id, s.seller_city, s.seller_state
    HAVING COUNT(DISTINCT o.order_id) >= 10
),
medians AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue) AS median_revenue,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_review_score) AS median_review
    FROM seller_stats
)
SELECT
    ss.seller_id,
    ss.seller_city,
    ss.seller_state,
    ss.orders,
    ss.revenue,
    ss.avg_review_score,
    ss.late_pct,
    m.median_revenue,
    m.median_review,
    CASE
        WHEN ss.revenue >= m.median_revenue AND ss.avg_review_score >= m.median_review
            THEN 'Star'        -- high revenue, high satisfaction
        WHEN ss.revenue >= m.median_revenue AND ss.avg_review_score < m.median_review
            THEN 'Risk'        -- high revenue but poor satisfaction: business risk
        WHEN ss.revenue < m.median_revenue AND ss.avg_review_score >= m.median_review
            THEN 'Niche'       -- low revenue but happy customers: growth potential
        ELSE
            'Underperformer'   -- low revenue and poor satisfaction
    END AS quadrant
FROM seller_stats ss
CROSS JOIN medians m
ORDER BY ss.revenue DESC;

-- Quadrant summary: how many sellers in each, and what do they contribute?
WITH seller_stats AS (
    SELECT
        s.seller_id,
        COUNT(DISTINCT o.order_id) AS orders,
        ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS revenue,
        ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score,
        ROUND(100.0 * COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
        ) / COUNT(*)::numeric, 1) AS late_pct
    FROM sellers s
    JOIN order_items oi ON s.seller_id = oi.seller_id
    JOIN orders o ON oi.order_id = o.order_id
    LEFT JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
        AND o.order_purchase_timestamp >= '2016-10-01'
        AND o.order_purchase_timestamp < '2018-09-01'
        AND DATE_TRUNC('month', o.order_purchase_timestamp) <> '2016-12-01'
        AND o.order_delivered_customer_date IS NOT NULL
        AND o.is_date_sequence_valid = true
    GROUP BY s.seller_id
    HAVING COUNT(DISTINCT o.order_id) >= 10
),
medians AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue) AS median_revenue,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_review_score) AS median_review
    FROM seller_stats
),
quadrants AS (
    SELECT
        ss.*,
        CASE
            WHEN ss.revenue >= m.median_revenue AND ss.avg_review_score >= m.median_review
                THEN 'Star'
            WHEN ss.revenue >= m.median_revenue AND ss.avg_review_score < m.median_review
                THEN 'Risk'
            WHEN ss.revenue < m.median_revenue AND ss.avg_review_score >= m.median_review
                THEN 'Niche'
            ELSE 'Underperformer'
        END AS quadrant
    FROM seller_stats ss
    CROSS JOIN medians m
)
SELECT
    quadrant,
    COUNT(*) AS sellers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()::numeric, 1) AS pct_of_sellers,
    ROUND(SUM(revenue)::numeric, 2) AS total_revenue,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER ()::numeric, 1) AS pct_of_revenue,
    ROUND(AVG(revenue)::numeric, 2) AS avg_revenue,
    ROUND(AVG(avg_review_score)::numeric, 2) AS avg_review_score,
    ROUND(AVG(late_pct)::numeric, 1) AS avg_late_pct,
    ROUND(AVG(orders)::numeric, 0) AS avg_orders
FROM quadrants
GROUP BY quadrant
ORDER BY total_revenue DESC;
