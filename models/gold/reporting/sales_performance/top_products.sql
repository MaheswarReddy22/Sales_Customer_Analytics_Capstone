SELECT

    p.product_name,

    SUM(f.quantity_sold) AS quantity_sold,

    SUM(f.line_revenue) AS sales

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_product') }} p
ON f.product_key = p.product_key

GROUP BY
    p.product_name

ORDER BY
    SUM(f.line_revenue) DESC