WITH orders AS (

    SELECT *
    FROM {{ ref('stg_orders') }}

),

transformed AS (

    SELECT

        order_id,

        customer_id,

        employee_id,

        store_id,

        campaign_id,

        product_id,

        order_source,

        order_status,

        payment_method,

        shipping_method,

        quantity,

        unit_price,

        cost_price,

        item_discount_amount,

        order_discount_amount,

        shipping_cost,

        tax_amount,

        total_amount,

        (
            quantity
            * unit_price
            * (1 - (item_discount_amount / 100.0))
        ) AS line_revenue,

        (
            quantity * cost_price
        ) AS line_cost,

        (
            (
                quantity
                * unit_price
                * (1 - (item_discount_amount / 100.0))
            )
            *
            (1 - (order_discount_amount / 100.0))
        )
        - (quantity * cost_price)
        - shipping_cost
        - tax_amount
        AS profit_amount,

        CASE

            WHEN
            (
                quantity
                * unit_price
                * (1 - (item_discount_amount / 100.0))
            ) > 0

            THEN

                (
                    (
                        (
                            quantity
                            * unit_price
                            * (1 - (item_discount_amount / 100.0))
                        )
                        *
                        (1 - (order_discount_amount / 100.0))
                    )
                    - (quantity * cost_price)
                    - shipping_cost
                    - tax_amount
                )

                /

                (
                    quantity
                    * unit_price
                    * (1 - (item_discount_amount / 100.0))
                )

                * 100

            ELSE NULL

        END AS profit_margin_percentage,

        EXTRACT(HOUR FROM order_date) AS order_hour,

        CASE
            WHEN EXTRACT(HOUR FROM order_date) >= 5
                 AND EXTRACT(HOUR FROM order_date) < 12
                THEN 'Morning'

            WHEN EXTRACT(HOUR FROM order_date) >= 12
                 AND EXTRACT(HOUR FROM order_date) < 17
                THEN 'Afternoon'

            WHEN EXTRACT(HOUR FROM order_date) >= 17
                 AND EXTRACT(HOUR FROM order_date) < 22
                THEN 'Evening'

            ELSE 'Night'

        END AS order_time_of_day,

        DATE_TRUNC('week', order_date) AS order_week,

        DATE_TRUNC('month', order_date) AS order_month,

        DATE_TRUNC('quarter', order_date) AS order_quarter,

        DATE_TRUNC('year', order_date) AS order_year,

        DATEDIFF(day, order_date, shipping_date) AS processing_days,

        DATEDIFF(day, shipping_date, delivery_date) AS shipping_days,

        CASE

            WHEN delivery_date IS NOT NULL
                 AND delivery_date <= estimated_delivery_date
                THEN 'On Time'

            WHEN delivery_date IS NOT NULL
                 AND delivery_date > estimated_delivery_date
                THEN 'Delayed'

            WHEN delivery_date IS NULL
                 AND CURRENT_DATE() > estimated_delivery_date
                THEN 'Potentially Delayed'

            ELSE 'In Transit'

        END AS delivery_status,

        billing_street,

        billing_city,

        billing_state,

        billing_zip_code,

        shipping_street,

        shipping_city,

        shipping_state,

        shipping_zip_code,

        order_date,

        created_at,

        shipping_date,

        delivery_date,

        estimated_delivery_date,

        _source_file,

        _loaded_at,

        _batch_id

    FROM orders

)

SELECT *
FROM transformed