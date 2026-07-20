SELECT

    p.category,

    COUNT(DISTINCT f.order_id) AS total_orders,

    SUM(f.quantity_sold) AS total_quantity_sold,

    ROUND(SUM(f.gross_sales_amount), 2) AS total_sales,

    ROUND(SUM(f.profit_amount), 2) AS total_profit,

    ROUND(AVG(f.profit_margin_percentage), 2) AS average_profit_margin

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_product') }} p
    ON f.product_key = p.product_key

GROUP BY p.category

ORDER BY total_sales DESC;