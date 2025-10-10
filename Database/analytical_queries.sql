-- Olist: Optimized Analytical SQL Queries

-- TIME BASED TREND ANALYSIS --
----------------------------------------------------------
-- Query 1: Year-over-Year Revenue Growth
----------------------------------------------------------
SELECT
    d.year_number AS year,
    SUM(fs.total_item_value) AS total_revenue,
    LAG(SUM(fs.total_item_value)) OVER (ORDER BY d.year_number) AS prev_year_revenue,
    ROUND(
        (SUM(fs.total_item_value) - LAG(SUM(fs.total_item_value)) OVER (ORDER BY d.year_number)) 
        / NULLIF(LAG(SUM(fs.total_item_value)) OVER (ORDER BY d.year_number), 0) * 100, 
        2
    ) AS yoy_growth_percent
FROM fact_sales fs
JOIN dim_date d ON fs.purchase_date_key = d.date_key
GROUP BY d.year_number
ORDER BY d.year_number;

----------------------------------------------------------
-- Query 2: Seasonal Pattern Analysis
----------------------------------------------------------
SELECT
    d.year_number,
    d.month_number,
    d.month_name,
    SUM(fs.total_item_value) AS monthly_revenue,
    ROUND(AVG(SUM(fs.total_item_value)) OVER (PARTITION BY d.month_number), 2) AS seasonal_avg
FROM fact_sales fs
JOIN dim_date d ON fs.purchase_date_key = d.date_key
GROUP BY d.year_number, d.month_number, d.month_name
ORDER BY d.year_number, d.month_number;

-- DRILL-DOWN AND ROLL-UP OPERATIONS --
----------------------------------------------------------
-- Query 3: Time Hierarchy Drill-down
----------------------------------------------------------
SELECT
    d.year_number,
    d.quarter_number,
    d.month_number,
    COUNT(*) AS sales_count,
    SUM(fs.total_item_value) AS revenue
FROM fact_sales fs
JOIN dim_date d ON fs.purchase_date_key = d.date_key
GROUP BY ROLLUP (d.year_number, d.quarter_number, d.month_number)
ORDER BY d.year_number, d.quarter_number, d.month_number;

----------------------------------------------------------
-- Query 4: Geographic Hierarchy Drill-down
----------------------------------------------------------
SELECT
    dc.customer_region,
    dc.customer_state,
    COUNT(*) AS sales_count,
    SUM(fs.total_item_value) AS total_revenue
FROM fact_sales fs
JOIN dim_customer dc ON fs.customer_key = dc.customer_key
WHERE dc.is_current = TRUE
GROUP BY ROLLUP (dc.customer_region, dc.customer_state)
ORDER BY dc.customer_region, dc.customer_state;

-- ADVANCED WINDOW FUNCTIONS --
----------------------------------------------------------
-- Query 5: Customer Revenue Ranking
----------------------------------------------------------
SELECT
    c.customer_unique_id,
    SUM(fs.total_item_value) AS total_revenue,
    RANK() OVER (ORDER BY SUM(fs.total_item_value) DESC) AS revenue_rank,
    ROUND(PERCENT_RANK() OVER (ORDER BY SUM(fs.total_item_value) DESC)::numeric, 4) AS revenue_percentile
FROM fact_sales fs
JOIN dim_customer c ON fs.customer_key = c.customer_key
WHERE c.is_current = TRUE
GROUP BY c.customer_unique_id
HAVING SUM(fs.total_item_value) > 500  -- Focus on meaningful customers
ORDER BY total_revenue DESC
LIMIT 100;

----------------------------------------------------------
-- Query 6: Moving Average
----------------------------------------------------------
WITH monthly_sales AS (
    SELECT
        d.year_number,
        d.month_number,
        SUM(fs.total_item_value) AS monthly_revenue
    FROM fact_sales fs
    JOIN dim_date d ON fs.purchase_date_key = d.date_key
    GROUP BY d.year_number, d.month_number
)
SELECT
    year_number,
    month_number,
    monthly_revenue,
    ROUND(
        AVG(monthly_revenue) OVER (
            ORDER BY year_number, month_number
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS moving_avg_3months,
    SUM(monthly_revenue) OVER (
        ORDER BY year_number, month_number
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_revenue
FROM monthly_sales
ORDER BY year_number, month_number;

-- COMPLEX FILTERING AND SUBQUERIES --
----------------------------------------------------------
-- Query 7: Multi-dimensional Filtering with EXISTS
----------------------------------------------------------
SELECT
    c.customer_unique_id,
    c.customer_region,
    COUNT(DISTINCT fs.seller_key) AS distinct_sellers,
    SUM(fs.total_item_value) AS total_spent
FROM dim_customer c
JOIN fact_sales fs ON c.customer_key = fs.customer_key
WHERE c.is_current = TRUE
    AND EXISTS (
        SELECT 1 FROM fact_customer_reviews fcr 
        WHERE fcr.customer_key = c.customer_key
    )
GROUP BY c.customer_unique_id, c.customer_region
HAVING COUNT(DISTINCT fs.seller_key) >= 2  -- Bought from multiple sellers
    AND SUM(fs.total_item_value) > 300    -- Minimum spending threshold
ORDER BY total_spent DESC
LIMIT 50;

----------------------------------------------------------
-- Query 8: Correlated Subquery - Above Average Customers
----------------------------------------------------------
WITH customer_totals AS (
    SELECT
        c.customer_unique_id,
        c.customer_region,
        SUM(fs.total_item_value) AS customer_total
    FROM dim_customer c
    JOIN fact_sales fs ON c.customer_key = fs.customer_key
    WHERE c.is_current = TRUE
    GROUP BY c.customer_unique_id, c.customer_region
),
regional_avg AS (
    SELECT
        customer_region,
        AVG(customer_total) AS region_avg
    FROM customer_totals
    GROUP BY customer_region
)
SELECT 
    ct.customer_unique_id,
    ct.customer_region,
    ROUND(ct.customer_total::numeric, 2) AS customer_total,
    ROUND(ra.region_avg::numeric, 2) AS region_avg,
    ROUND((ct.customer_total - ra.region_avg)::numeric, 2) AS above_avg_amount
FROM customer_totals ct
JOIN regional_avg ra ON ct.customer_region = ra.customer_region
WHERE ct.customer_total > ra.region_avg * 1.2  -- 20% above regional average
ORDER BY above_avg_amount DESC
LIMIT 30;

-- BUSINESS INTELLIGENCE METRICS --
----------------------------------------------------------
-- Query 9: Customer Profitability Analysis
----------------------------------------------------------
SELECT
    c.customer_unique_id,
    c.customer_region,
    COUNT(DISTINCT fs.order_id) AS total_orders,
    SUM(fs.total_item_value) AS total_revenue,
    ROUND(SUM(fs.total_item_value) / COUNT(DISTINCT fs.order_id), 2) AS avg_order_value,
    COUNT(DISTINCT dp.product_category_english) AS category_diversity,
    CASE 
        WHEN SUM(fs.total_item_value) >= 1500 THEN 'VIP'
        WHEN SUM(fs.total_item_value) >= 750 THEN 'Premium'
        WHEN SUM(fs.total_item_value) >= 300 THEN 'Standard'
        ELSE 'Basic'
    END AS customer_segment
FROM dim_customer c
JOIN fact_sales fs ON c.customer_key = fs.customer_key
JOIN dim_product dp ON fs.product_key = dp.product_key
WHERE c.is_current = TRUE
GROUP BY c.customer_unique_id, c.customer_region
HAVING COUNT(DISTINCT fs.order_id) >= 2  -- Exclude one-time buyers
ORDER BY total_revenue DESC
LIMIT 100;

----------------------------------------------------------
-- Query 10: Seller Performance KPIs
----------------------------------------------------------
SELECT
    s.seller_id,
    s.seller_region,
    COUNT(DISTINCT fs.order_id) AS total_orders,
    SUM(fs.total_item_value) AS total_revenue,
    ROUND(SUM(fs.total_item_value) / COUNT(DISTINCT fs.order_id), 2) AS avg_order_value,
    COUNT(DISTINCT fs.customer_key) AS unique_customers,
    -- Delivery performance (simplified)
    ROUND(AVG(fdp.delivery_performance_score)::numeric, 2) AS avg_delivery_score,
    ROUND(
        SUM(CASE WHEN fdp.is_on_time THEN 1 ELSE 0 END)::DECIMAL / 
        NULLIF(COUNT(fdp.order_id), 0) * 100, 
        1
    ) AS on_time_percentage,
    -- Performance rating
    CASE 
        WHEN AVG(fdp.delivery_performance_score) >= 0.85 THEN 'Excellent'
        WHEN AVG(fdp.delivery_performance_score) >= 0.70 THEN 'Good'
        WHEN AVG(fdp.delivery_performance_score) >= 0.55 THEN 'Average'
        ELSE 'Needs Improvement'
    END AS performance_rating
FROM dim_seller s
JOIN fact_sales fs ON s.seller_key = fs.seller_key
LEFT JOIN fact_delivery_performance fdp ON fs.order_id = fdp.order_id
GROUP BY s.seller_id, s.seller_region
HAVING COUNT(DISTINCT fs.order_id) >= 5  -- Focus on active sellers
ORDER BY total_revenue DESC
LIMIT 50;