WITH order_totals AS (

    SELECT
        order_id,
        COUNT(product_id) AS total_items,
        SUM(quantity) AS total_quantity,
        SUM(quantity * unit_price) AS total_amount,
        SUM(quantity * cost_price) AS total_cost,
        SUM(item_discount_amount) AS total_discount

    FROM {{ ref('stg_orders') }}

    GROUP BY order_id

)

SELECT *
FROM order_totals