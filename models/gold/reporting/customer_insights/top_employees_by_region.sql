SELECT

    s.region,

    e.employee_id,

    e.full_name,

    e.role,

    COUNT(DISTINCT f.order_id) AS orders_handled,

    ROUND(SUM(f.gross_sales_amount),2) AS total_sales,

    ROUND(SUM(f.profit_amount),2) AS total_profit,

    e.target_achievement_percentage,

    DENSE_RANK() OVER(

        PARTITION BY s.region

        ORDER BY SUM(f.gross_sales_amount) DESC

    ) AS regional_rank

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_employee') }} e
    ON f.employee_key = e.employee_key

JOIN {{ ref('dim_store') }} s
    ON f.store_key = s.store_key

GROUP BY

    s.region,
    e.employee_id,
    e.full_name,
    e.role,
    e.target_achievement_percentage

ORDER BY

    s.region,
    regional_rank