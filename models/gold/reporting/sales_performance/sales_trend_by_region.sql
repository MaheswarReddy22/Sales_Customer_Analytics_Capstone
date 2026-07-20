SELECT

    s.region,

    SUM(f.line_revenue) AS total_sales,

    SUM(f.profit_amount) AS total_profit

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_date') }} d
ON f.date_key = d.date_key

JOIN {{ ref('dim_store') }} s
ON f.store_key = s.store_key

GROUP BY

    s.region