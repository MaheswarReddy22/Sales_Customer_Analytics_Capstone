WITH employee_sales AS (

    SELECT

        e.full_name,

        s.region,

        SUM(f.line_revenue) AS total_sales

    FROM {{ ref('fact_sales') }} f

    JOIN {{ ref('dim_employee') }} e
        ON f.employee_key = e.employee_key

    JOIN {{ ref('dim_store') }} s
        ON f.store_key = s.store_key

    GROUP BY

        e.full_name,

        s.region

),

ranked AS (

    SELECT

        *,

        ROW_NUMBER() OVER (

            PARTITION BY region

            ORDER BY total_sales DESC

        ) AS rn

    FROM employee_sales

)

SELECT

    full_name,

    region,

    total_sales

FROM ranked

WHERE rn = 1

ORDER BY region