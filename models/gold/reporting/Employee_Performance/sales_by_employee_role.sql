SELECT

    e.role,

    SUM(f.line_revenue) AS total_sales,

    SUM(f.profit_amount) AS total_profit

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_employee') }} e
ON f.employee_key = e.employee_key

GROUP BY e.role