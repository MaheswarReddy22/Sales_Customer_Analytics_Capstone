SELECT

    c.customer_id,

    c.full_name,

    COUNT(DISTINCT f.order_id) AS total_orders,

    SUM(f.line_revenue) AS total_spend,

    AVG(f.line_revenue) AS average_order_value

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_customer') }} c
ON f.customer_key = c.customer_key

GROUP BY

    c.customer_id,
    c.full_name