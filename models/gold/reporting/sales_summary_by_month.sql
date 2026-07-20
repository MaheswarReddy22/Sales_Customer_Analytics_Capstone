WITH sales AS (

    SELECT *
    FROM {{ ref('fact_sales') }}

),

dates AS (

    SELECT *
    FROM {{ ref('dim_date') }}

)

SELECT

    d.year,
    d.quarter,
    d.month,
    d.month_name,

    COUNT(DISTINCT s.order_id) AS total_orders,

    SUM(s.quantity_sold) AS total_quantity_sold,

    ROUND(SUM(s.gross_sales_amount),2) AS total_sales,

    ROUND(SUM(s.profit_amount),2) AS total_profit,

    ROUND(AVG(s.gross_sales_amount),2) AS average_order_value

FROM sales s

JOIN dates d
ON s.date_key = d.date_key

GROUP BY

    d.year,
    d.quarter,
    d.month,
    d.month_name

ORDER BY

    d.year,
    d.month