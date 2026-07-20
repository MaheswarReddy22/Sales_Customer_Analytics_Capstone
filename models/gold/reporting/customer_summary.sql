WITH sales AS (

    SELECT *
    FROM {{ ref('fact_sales') }}

),

customers AS (

    SELECT *
    FROM {{ ref('dim_customer') }}
    WHERE is_current = TRUE

)

SELECT

    c.customer_id,

    c.full_name,

    c.loyalty_tier,

    c.age_segment,

    COUNT(DISTINCT s.order_id) AS total_orders,

    ROUND(SUM(s.gross_sales_amount),2) AS lifetime_sales,

    ROUND(SUM(s.profit_amount),2) AS lifetime_profit,

    ROUND(AVG(s.gross_sales_amount),2) AS average_order_value

FROM sales s

JOIN customers c
ON s.customer_key = c.customer_key

GROUP BY

    c.customer_id,
    c.full_name,
    c.loyalty_tier,
    c.age_segment

ORDER BY lifetime_sales DESC