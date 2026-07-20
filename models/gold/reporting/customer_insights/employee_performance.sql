SELECT

    de.employee_id,
    de.full_name,
    de.department,
    de.role,

    COUNT(fs.order_id) AS total_orders,

    SUM(fs.line_revenue) AS total_sales,

    SUM(fs.profit_amount) AS total_profit,

    AVG(fs.processing_days) AS average_processing_days

FROM {{ ref('fact_sales') }} fs

JOIN {{ ref('dim_employee') }} de
ON fs.employee_key = de.employee_key

GROUP BY

    de.employee_id,
    de.full_name,
    de.department,
    de.role