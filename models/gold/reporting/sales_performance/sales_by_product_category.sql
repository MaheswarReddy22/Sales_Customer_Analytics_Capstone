SELECT

    p.category,

    p.subcategory,

    SUM(f.line_revenue) AS total_sales,

    SUM(f.quantity_sold) AS total_quantity,

    SUM(f.profit_amount) AS total_profit

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_product') }} p
ON f.product_key = p.product_key

GROUP BY

    p.category,
    p.subcategory

ORDER BY total_sales DESC