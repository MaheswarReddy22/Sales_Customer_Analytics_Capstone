SELECT

    e.tenure,

    AVG(e.performance_rating) AS average_performance_rating,

    AVG(e.target_achievement_percentage) AS average_target_achievement,

    SUM(e.orders_processed) AS total_orders_processed,

    SUM(e.total_sales_amount) AS total_sales_amount

FROM {{ ref('dim_employee') }} e

GROUP BY e.tenure

ORDER BY e.tenure DESC