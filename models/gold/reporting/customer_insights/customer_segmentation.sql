SELECT

    c.age_segment,

    c.loyalty_tier,

    c.income_bracket,

    COUNT(DISTINCT c.customer_id) AS customer_count,

    COUNT(DISTINCT f.order_id) AS total_orders,

    ROUND(SUM(f.gross_sales_amount),2) AS total_revenue,

    ROUND(SUM(f.profit_amount),2) AS total_profit,

    ROUND(
        SUM(f.gross_sales_amount)
        /
        NULLIF(COUNT(DISTINCT c.customer_id),0),
        2
    ) AS revenue_per_customer,

    ROUND(
        SUM(f.quantity_sold)
        /
        NULLIF(COUNT(DISTINCT c.customer_id),0),
        2
    ) AS average_items_per_customer

FROM {{ ref('dim_customer') }} c

LEFT JOIN {{ ref('fact_sales') }} f
    ON c.customer_key = f.customer_key

GROUP BY

    c.age_segment,
    c.loyalty_tier,
    c.income_bracket

ORDER BY total_revenue DESC