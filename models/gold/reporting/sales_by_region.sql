WITH sales AS (

    SELECT *
    FROM {{ ref('fact_sales') }}

)

SELECT

    region,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(quantity_sold) AS quantity_sold,

    ROUND(SUM(gross_sales_amount),2) AS total_sales,

    ROUND(SUM(profit_amount),2) AS total_profit,

    ROUND(AVG(gross_sales_amount),2) AS average_order_value

FROM sales

GROUP BY region

ORDER BY total_sales DESC