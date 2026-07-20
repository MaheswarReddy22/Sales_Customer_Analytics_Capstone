SELECT

    e.employee_id,

    e.full_name,

    e.role,

    e.department,

    e.performance_rating,

    e.target_achievement_percentage,

    e.orders_processed,

    e.tenure,

    COUNT(DISTINCT f.order_id) AS orders_handled,

    ROUND(SUM(f.gross_sales_amount),2) AS total_sales,

    ROUND(SUM(f.profit_amount),2) AS total_profit,

    ROUND(AVG(f.profit_margin_percentage),2) AS average_profit_margin

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_employee') }} e
    ON f.employee_key = e.employee_key

GROUP BY

    e.employee_id,
    e.full_name,
    e.role,
    e.department,
    e.performance_rating,
    e.target_achievement_percentage,
    e.orders_processed,
    e.tenure

ORDER BY total_sales DESC;