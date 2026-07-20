SELECT

    e.role,

    COUNT(DISTINCT e.employee_id) AS employee_count,

    COUNT(DISTINCT f.order_id) AS total_orders,

    ROUND(SUM(f.gross_sales_amount),2) AS total_sales,

    ROUND(SUM(f.profit_amount),2) AS total_profit,

    ROUND(AVG(e.target_achievement_percentage),2) AS avg_target_achievement,

    ROUND(
        SUM(f.gross_sales_amount)
        /
        NULLIF(COUNT(DISTINCT e.employee_id),0),
        2
    ) AS sales_per_employee

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_employee') }} e
    ON f.employee_key = e.employee_key

GROUP BY e.role

ORDER BY total_sales DESC;