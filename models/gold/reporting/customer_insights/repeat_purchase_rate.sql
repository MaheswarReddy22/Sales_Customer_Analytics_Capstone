WITH customer_order_counts AS (

    SELECT

        c.customer_id,

        COUNT(DISTINCT f.order_id) AS order_count

    FROM {{ ref('fact_sales') }} f

    JOIN {{ ref('dim_customer') }} c
        ON f.customer_key = c.customer_key

    GROUP BY c.customer_id

)

SELECT

    COUNT(*) AS total_customers,

    COUNT(CASE WHEN order_count > 1 THEN 1 END) AS repeat_customers,

    COUNT(CASE WHEN order_count = 1 THEN 1 END) AS one_time_customers,

    ROUND(
        COUNT(CASE WHEN order_count > 1 THEN 1 END) * 100.0
        / NULLIF(COUNT(*),0),
        2
    ) AS repeat_purchase_rate

FROM customer_order_counts