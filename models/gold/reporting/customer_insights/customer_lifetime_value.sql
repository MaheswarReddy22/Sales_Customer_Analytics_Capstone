SELECT

    c.customer_id,

    c.full_name,

    SUM(f.line_revenue) AS customer_lifetime_value

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_customer') }} c
ON f.customer_key = c.customer_key

GROUP BY

    c.customer_id,
    c.full_name

ORDER BY customer_lifetime_value DESC