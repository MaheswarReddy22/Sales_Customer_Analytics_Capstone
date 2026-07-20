SELECT

    s.region,

    d.year,

    d.quarter,

    d.month,

    d.month_name,

    COUNT(DISTINCT f.order_id) AS total_orders,

    SUM(f.quantity_sold) AS total_quantity,

    ROUND(SUM(f.gross_sales_amount), 2) AS total_sales,

    ROUND(SUM(f.profit_amount), 2) AS total_profit,

    ROUND(AVG(f.processing_days),2) AS avg_processing_days

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_store') }} s
    ON f.store_key = s.store_key

JOIN {{ ref('dim_date') }} d
    ON f.date_key = d.date_key

GROUP BY
    s.region,
    d.year,
    d.quarter,
    d.month,
    d.month_name

ORDER BY
    s.region,
    d.year,
    d.month