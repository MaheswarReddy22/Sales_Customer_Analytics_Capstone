SELECT

    e.employee_id,

    e.full_name,

    e.role,

    e.tenure,

    CASE
        WHEN e.tenure < 1 THEN '0-1 Year'
        WHEN e.tenure BETWEEN 1 AND 3 THEN '1-3 Years'
        WHEN e.tenure BETWEEN 4 AND 6 THEN '4-6 Years'
        ELSE '7+ Years'
    END AS tenure_band,

    e.performance_rating,

    e.target_achievement_percentage,

    COUNT(DISTINCT f.order_id) AS total_orders,

    ROUND(SUM(f.gross_sales_amount),2) AS total_sales,

    ROUND(SUM(f.profit_amount),2) AS total_profit,

    ROUND(AVG(f.profit_margin_percentage),2) AS average_profit_margin

FROM {{ ref('dim_employee') }} e

LEFT JOIN {{ ref('fact_sales') }} f
    ON e.employee_key = f.employee_key

GROUP BY

    e.employee_id,
    e.full_name,
    e.role,
    e.tenure,
    e.performance_rating,
    e.target_achievement_percentage

ORDER BY

    e.tenure DESC,
    total_sales DESC;