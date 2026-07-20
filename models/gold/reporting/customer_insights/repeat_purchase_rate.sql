WITH customer_orders AS (

    SELECT

        customer_key,

        COUNT(DISTINCT order_id) AS order_count

    FROM {{ ref('fact_sales') }}

    GROUP BY customer_key

)

SELECT

    ROUND(
        COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_key END)
        * 100.0
        / COUNT(DISTINCT customer_key),
        2
    ) AS repeat_purchase_rate

FROM customer_orders