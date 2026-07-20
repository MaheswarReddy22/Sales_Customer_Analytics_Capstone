SELECT

    c.customer_id,

    c.full_name,

    c.loyalty_tier,

    c.age_segment,

    c.income_bracket,

    COUNT(DISTINCT f.order_id) AS total_orders,

    SUM(f.quantity_sold) AS total_items_purchased,

    ROUND(SUM(f.gross_sales_amount),2) AS total_spent,

    ROUND(
        SUM(f.gross_sales_amount)
        /
        NULLIF(COUNT(DISTINCT f.order_id),0),
        2
    ) AS average_order_value,

    ROUND(SUM(f.profit_amount),2) AS total_profit,

    MIN(f.order_date) AS first_purchase_date,

    MAX(f.order_date) AS last_purchase_date,

    DATEDIFF(
        day,
        MIN(f.order_date),
        MAX(f.order_date)
    ) AS purchasing_span_days

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_customer') }} c
    ON f.customer_key = c.customer_key

GROUP BY

    c.customer_id,
    c.full_name,
    c.loyalty_tier,
    c.age_segment,
    c.income_bracket

ORDER BY total_spent DESC