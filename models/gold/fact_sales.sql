-- Grain: One row per order line item (OrderID + ProductID)

WITH orders AS (

    SELECT
        *,
        SUM(line_revenue) OVER (PARTITION BY order_id) AS order_total_line_revenue
    FROM {{ ref('stg_orders_transformed') }}

),

allocated AS (

    SELECT

        *,

        CASE
            WHEN order_total_line_revenue > 0
            THEN line_revenue / order_total_line_revenue
            ELSE 0
        END AS revenue_share,

        shipping_cost *
        CASE
            WHEN order_total_line_revenue > 0
            THEN line_revenue / order_total_line_revenue
            ELSE 0
        END AS allocated_shipping_cost,

        tax_amount *
        CASE
            WHEN order_total_line_revenue > 0
            THEN line_revenue / order_total_line_revenue
            ELSE 0
        END AS allocated_tax_amount,

        (quantity * unit_price * item_discount_amount) AS discount_amount_dollars

    FROM orders

),

final AS (

    SELECT

        {{ dbt_utils.generate_surrogate_key(['a.order_id', 'a.product_id']) }} AS sales_key,

        a.order_id,

        d.date_key,

        c.customer_key,

        p.product_key,

        s.store_key,

        e.employee_key,

        a.customer_id,

        a.product_id,

        a.store_id,

        a.employee_id,

        a.quantity AS quantity_sold,

        a.unit_price,

        a.cost_price,

        (a.quantity * a.unit_price) AS gross_sales_amount,

        a.discount_amount_dollars AS discount_amount,

        a.allocated_shipping_cost AS shipping_cost,

        a.allocated_tax_amount AS tax_amount,

        a.line_revenue,

        a.line_cost,

        a.profit_amount,

        a.profit_margin_percentage,

        a.processing_days,

        a.shipping_days,

        a.delivery_status,

        a.order_source,

        a.order_status,

        a.payment_method,

        a.shipping_method,

        a.order_time_of_day,

        a.order_hour,

        a.order_week,

        a.order_month,

        a.order_quarter,

        a.order_year,

        c.age_segment AS customer_segment_impact,

        CASE
            WHEN LOWER(a.order_source) LIKE '%online%'
            THEN 'Online'
            ELSE 'In-Store'
        END AS sales_channel,

        s.region,

        a.created_at,

        a.order_date,

        a.shipping_date,

        a.delivery_date,

        a.estimated_delivery_date

    FROM allocated a

    LEFT JOIN {{ ref('dim_customer') }} c
        ON a.customer_id = c.customer_id
       AND a.order_date >= c.valid_from
       AND (
            c.valid_to IS NULL
            OR a.order_date < c.valid_to
       )

    LEFT JOIN {{ ref('dim_product') }} p
        ON a.product_id = p.product_id

    LEFT JOIN {{ ref('dim_store') }} s
        ON a.store_id = s.store_id

    LEFT JOIN {{ ref('dim_employee') }} e
        ON a.employee_id = e.employee_id

    LEFT JOIN {{ ref('dim_date') }} d
        ON CAST(a.order_date AS DATE) = d.full_date

)

SELECT *
FROM final