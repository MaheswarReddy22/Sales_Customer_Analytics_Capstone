SELECT

    p.product_name,

    p.category,

    p.brand,

    SUM(f.quantity_sold) AS total_quantity_sold,

    ROUND(SUM(f.gross_sales_amount),2) AS total_sales,

    ROUND(SUM(f.profit_amount),2) AS total_profit,

    ROUND(AVG(f.profit_margin_percentage),2) AS average_profit_margin,

    DENSE_RANK() OVER(
        ORDER BY SUM(f.gross_sales_amount) DESC
    ) AS sales_rank

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_product') }} p
    ON f.product_key = p.product_key

GROUP BY

    p.product_name,
    p.category,
    p.brand

ORDER BY sales_rank;