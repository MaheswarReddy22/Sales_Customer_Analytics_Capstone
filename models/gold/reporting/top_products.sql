WITH sales AS (

    SELECT *
    FROM {{ ref('fact_sales') }}

),

products AS (

    SELECT *
    FROM {{ ref('dim_product') }}

)

SELECT

    p.product_name,

    p.category,

    SUM(s.quantity_sold) AS quantity_sold,

    ROUND(SUM(s.gross_sales_amount),2) AS revenue,

    ROUND(SUM(s.profit_amount),2) AS profit,

    DENSE_RANK() OVER(
        ORDER BY SUM(s.gross_sales_amount) DESC
    ) AS sales_rank

FROM sales s

JOIN products p
ON s.product_key = p.product_key

GROUP BY

    p.product_name,
    p.category

ORDER BY sales_rank