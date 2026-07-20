SELECT

    c.customer_id,

    c.full_name,

    c.loyalty_tier,

    c.age_segment,

    c.registration_date,

    COUNT(DISTINCT f.order_id) AS lifetime_orders,

    ROUND(SUM(f.gross_sales_amount),2) AS lifetime_value,

    ROUND(SUM(f.profit_amount),2) AS lifetime_profit,

    ROUND(
        SUM(f.gross_sales_amount)
        /
        NULLIF(COUNT(DISTINCT f.order_id),0),
        2
    ) AS average_order_value,

    ROUND(
        AVG(f.profit_margin_percentage),
        2
    ) AS average_profit_margin

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_customer') }} c

ON f.customer_key = c.customer_key

GROUP BY

    c.customer_id,
    c.full_name,
    c.loyalty_tier,
    c.age_segment,
    c.registration_date

ORDER BY lifetime_value DESC