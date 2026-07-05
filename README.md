# Olist Brazilian E-Commerce Analysis
## SQL + Power BI Portfolio Project

---

## Project Overview

This project analyzes the **Olist Brazilian E-Commerce Public Dataset** (Kaggle), covering ~100,000 real e-commerce transactions from 2016 to 2018. The goal was to build a portfolio-quality end-to-end data analytics project demonstrating professional-grade data cleaning, SQL analysis, and business intelligence dashboard skills.

**Tools used:** PostgreSQL 16 · DBeaver 26.1.1 · Power BI Desktop  
**Dataset:** [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)  
**Analysis period:** October 2016 – August 2018 (23 months of complete data)

---

## Business Questions

1. How did revenue and order volume trend over time, and what drove the peak period?
2. Which product categories generate the most revenue, and what is the average ticket per category?
3. How does delivery performance vary across Brazil's 27 states?
4. Which customer segments hold the most value, and what is the platform's retention profile?
5. Which sellers are high-performing and which represent a business risk?

---

## Dataset Structure

8 relational tables with `orders` as the central table:

| Table | Rows | Description |
|---|---|---|
| orders | 99,441 | Central transaction table |
| customers | 99,441 | Customer location and unique ID |
| order_items | 112,650 | Line items with price and freight |
| order_payments | 103,886 | Payment method and installments |
| order_reviews | 70,000 | Star ratings and comments |
| products | 32,951 | Product dimensions and category |
| sellers | 3,095 | Seller location |
| geolocation | 1,000,163 → 720,115 | Zip code to lat/lng mapping (after cleaning) |
| product_category_name_translation | 71 (+3 added) | Portuguese to English category names |

---

## Data Cleaning

A complete, documented data cleaning process was applied to all 8 tables before any analysis. The full documentation is in [`data_cleaning_documentation.md`](./data_cleaning_documentation.md).

### Methodology: Fix / Flag / Leave

Every issue found was resolved using one of three decisions:
- **Fix** — clear technical error that would break analysis
- **Flag** — suspicious but potentially legitimate data, marked for optional filtering
- **Leave** — legitimate real-world behavior, not an error

### Key Cleaning Highlights

**Empty strings vs NULL (orders table)**
DBeaver imported empty CSV cells as `''` rather than NULL. Initial NULL checks appeared clean but 4,908 date rows were actually empty strings. Fixed by converting to proper NULL values. Lesson: always check both NULLs and empty strings after CSV import.

**Date columns imported as text (8 columns across 3 tables)**
PostgreSQL does not automatically infer timestamp types from CSV. All 8 date columns were stored as `character varying` and converted to `timestamp` using `ALTER TABLE ... USING column::timestamp`.

**Logical date sequence violations (1,382 orders)**
Carrier pickup timestamps appeared before approval timestamps in 1,382 orders — a known Olist dataset characteristic where physical shipping precedes digital approval logging. Decision: **Flag** (not delete) using a boolean column `is_date_sequence_valid`. These orders are real completed transactions with real revenue and are included in sales analysis but excluded from delivery time calculations.

**City name inconsistencies — fuzzy matching (customers and sellers tables)**
Used PostgreSQL's `pg_trgm` extension for fuzzy string matching rather than manual visual inspection. Found reversed word order, missing apostrophes, appended state codes, slash-duplicated entries, and extra whitespace. Fixed 8 inconsistencies in customers and 15+ in sellers.

**Unicode encoding bug (sellers table)**
Two versions of `santa barbara d'oeste` appeared identical (same character count, visually indistinguishable) but differed at character position 16: `chr(39)` standard apostrophe vs `chr(180)` acute accent. Found via ASCII code comparison. Fixed with `REPLACE(seller_city, chr(180), chr(39))`.

**Geolocation table deduplication (280,021 rows removed)**
The geolocation table is a geographic reference built by logging one entry per geocoding event — not a transaction log. 280,021 full-row duplicates existed (28% of the table). Deduplicated using `ROW_NUMBER()` window function partitioned over all 5 columns, chosen over `NOT IN (SELECT MIN(ctid)...)` due to performance considerations on large tables.

**Geolocation coordinate outliers (27 rows deleted)**
27 rows had coordinates outside Brazil's geographic bounding box (lat: -33.75 to +5.27, lng: -73.99 to -28.85), placing Brazilian cities in the Philippines, Mexico, and Europe. Decision: **Delete** — unlike flagged date sequences where underlying transactions were real, incorrect coordinates have no analytical value and would corrupt map visualizations.

**Geolocation city accent standardization (73,439 rows updated)**
2,036 city names existed in both accented (`são paulo`) and unaccented (`sao paulo`) forms. Standardized to unaccented lowercase using the `unaccent` PostgreSQL extension, consistent with the convention already applied to the customers and sellers tables. This fix was applied before deduplication so that accent variants correctly collapsed into single rows during the dedup step.

---

## Analysis & Key Findings

### 1. Revenue Trends

The dataset tells a three-act growth story:

**Act 1 — Hypergrowth (Oct 2016 → Nov 2017)**
Revenue grew from R$51K to R$1.17M in 13 months — approximately 22x growth. Month-over-month growth rates of 50–100%+ in early months indicate a marketplace finding product-market fit.

**Act 2 — Black Friday Validation (Nov 2017)**
A +53.3% MoM spike to R$1.17M — nearly double the previous month. This proves the platform was mature enough by late 2017 to capitalize on seasonal demand at scale.

**Act 3 — Maturity Plateau (Dec 2017 → Aug 2018)**
Revenue stabilized between R$996K and R$1.15M/month. Average order value declined slightly from R$177 (Oct 2016) to ~R$155 (2018) — a common marketplace maturation pattern as growth expands to a broader, lower-AOV customer base.

### 2. Category Revenue

Top 5 categories account for approximately 39% of total platform revenue:

| Rank | Category | Revenue | Revenue % | Avg Item Price |
|---|---|---|---|---|
| 1 | health_beauty | R$1.44M | 9.1% | R$130 |
| 2 | watches_gifts | R$1.30M | 8.3% | R$200 |
| 3 | bed_bath_table | R$1.24M | 7.9% | R$93 |
| 4 | sports_leisure | R$1.15M | 7.3% | R$114 |
| 5 | computers_accessories | R$1.05M | 6.7% | R$116 |

Notable: `computers` (181 orders, R$1,098 avg item price) is a high-ticket, low-volume outlier with a completely different commercial profile from volume categories.

### 3. Delivery Performance

**Platform-wide:** 95,095 delivered orders analyzed. Average actual delivery: 12.6 days vs 23.7 days promised — Olist delivers on average 11.1 days earlier than the customer-facing estimate. This is a deliberate under-promise/over-deliver strategy. Overall late rate: 8.2%.

**Regional disparity:** Customers in northern states wait 3.4x longer than São Paulo customers:

| State | Avg Days | Late % |
|---|---|---|
| SP (São Paulo) | 8.8 | 6.0% |
| MG (Minas Gerais) | 12.1 | 5.7% |
| RJ (Rio de Janeiro) | 15.4 | 13.6% |
| AL (Alagoas) | 24.4 | 23.7% |
| AM (Amazonas) | 26.4 | 4.2% |
| RR (Roraima) | 29.8 | 12.5% |

AL is a notable blind spot: 23.7% late rate despite "only" 24.4 days average, indicating estimated delivery promises are too optimistic for that state. AM by contrast has long delivery times but a low late rate (4.2%) — Olist learned to set conservative promises for the Amazon region.

### 4. Customer Segmentation (RFM Analysis)

RFM segmentation using quintile scoring (R = Recency, F = Frequency, M = Monetary):

| Segment | Customers | % of Customers | Total Revenue | % of Revenue |
|---|---|---|---|---|
| At Risk | 23,361 | 24.6% | R$5.65M | 35.9% |
| Champion | 14,812 | 15.6% | R$4.60M | 29.2% |
| Loyal | 18,815 | 19.8% | R$3.39M | 21.5% |
| Recent | 15,672 | 16.5% | R$875K | 5.6% |
| Lost | 14,632 | 15.4% | R$803K | 5.1% |
| Potential | 7,689 | 8.1% | R$421K | 2.7% |

**Key finding:** The At Risk segment — customers who purchased but haven't returned — represents 24.6% of customers but 35.9% of revenue. This is the highest-priority segment for re-engagement campaigns.

**Important context:** 97% of all customers purchased exactly once. The RFM frequency dimension has limited discriminating power on this dataset because Olist is a marketplace where customer relationships exist primarily with individual sellers, not the platform itself. Segmentation is driven almost entirely by recency and monetary value.

### 5. Seller Performance (Quadrant Analysis)

400 sellers with ≥10 orders were classified into performance quadrants using median revenue (R$4,794) and median review score (4.19) as thresholds:

| Quadrant | Sellers | % of Sellers | Revenue | % of Revenue | Avg Review | Avg Late % |
|---|---|---|---|---|---|---|
| Risk | 336 | 27.5% | R$7.24M | 52.2% | 3.85 | 9.7% |
| Star | 276 | 22.6% | R$5.19M | 37.4% | 4.40 | 6.0% |
| Niche | 336 | 27.5% | R$759K | 5.5% | 4.52 | 6.0% |
| Underperformer | 275 | 22.5% | R$673K | 4.9% | 3.74 | 9.8% |

**Key finding:** Risk sellers — high revenue but below-median satisfaction — generate 52.2% of platform revenue. Olist's commercial performance has significant dependency on sellers who are quietly damaging customer experience. Niche sellers have the highest satisfaction (4.52 avg review) but only 5.5% of revenue, representing a growth opportunity if the platform can help them scale.

---

## Power BI Dashboard

4-page interactive dashboard built in Power BI Desktop:

**Page 1 — Overview:** Monthly revenue trend with Black Friday annotation, KPI cards (total revenue, orders, AOV, customers)

**Page 2 — Geography:** Dual choropleth maps of Brazil showing average delivery days and late delivery rate by state, with state-level filter

**Page 3 — Customer Segmentation & Category Analysis:** RFM segment donut chart, revenue by segment bar chart, top 10 categories by revenue

**Page 4 — Seller Performance & Quadrant Analysis:** Seller count and revenue share by quadrant, review score vs late % comparison, platform KPI cards

**Note on data connection:** Dashboard uses CSV exports from PostgreSQL queries loaded into Power BI. A DAX calculated column (`state_full = "Brazil, " & [customer_state]`) was added in the Power BI data model to provide country context for accurate geocoding of Brazilian state abbreviations on the map visuals.

---

## How to Reproduce

**1. Download the dataset**
```python
import kagglehub
path = kagglehub.dataset_download("olistbr/brazilian-ecommerce")
```

**2. Set up PostgreSQL database**
```sql
CREATE DATABASE olist_ecommerce;
```
Import all CSV files into tables using DBeaver or `psql \copy` commands.

**3. Run data cleaning scripts**
Run the SQL scripts in `data_cleaning_documentation.md` in order, one table at a time.

**4. Run analysis queries**
Run the analysis queries from the `analysis/` folder to generate the 5 CSV exports.

**5. Open Power BI dashboard**
Open `olist_dashboard.pbix` and update the CSV file paths in Transform Data if needed.

---

## Project Structure

```
olist-ecommerce-analysis/
│
├── README.md
├── data_cleaning_documentation.md
│
├── analysis/
│   ├── 01_monthly_revenue.sql
│   ├── 02_category_revenue.sql
│   ├── 03_delivery_by_state.sql
│   ├── 04_rfm_segments.sql
│   └── 05_seller_quadrants.sql
│
├── exports/
│   ├── monthly_revenue.csv
│   ├── category_revenue.csv
│   ├── delivery_by_state.csv
│   ├── rfm_segments.csv
│   └── seller_quadrants.csv
│
└── olist_dashboard.pbix
```

---

## About This Project

Built as part of a junior Data Analyst / Data Engineer portfolio. The emphasis throughout was on documenting the reasoning behind every decision — not just what was done, but why — following the Fix / Flag / Leave framework for all data quality issues.

**Dataset:** Olist Brazilian E-Commerce Public Dataset · Kaggle  
**Period covered:** September 2016 – September 2018  
**Clean analysis window:** October 2016 – August 2018
