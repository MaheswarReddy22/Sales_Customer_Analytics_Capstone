WITH employees AS (

    SELECT *
    FROM {{ ref('stg_employees') }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY employee_id
        ORDER BY last_modified_date DESC
    ) = 1

),

employee_metrics AS (

    SELECT

        employee_id,

        COUNT(order_id) AS orders_processed,

        SUM(total_amount) AS total_sales_amount

    FROM {{ ref('stg_orders') }}

    GROUP BY employee_id

),

transformed AS (

    SELECT

        e.employee_id,

        e.first_name || ' ' || e.last_name AS full_name,

        e.first_name,

        e.last_name,

        CASE
            WHEN e.role = 'Sales Associate' THEN 'Associate'
            WHEN e.role = 'Senior Manager' THEN 'Senior Manager'
            WHEN e.role = 'Store Manager' THEN 'Manager'
            ELSE e.role
        END AS role,

        e.department,

        e.education,

        e.employment_status,

        e.manager_id,

        e.work_location,

        CASE
            WHEN e.email LIKE '%@%.%'
                 AND e.email NOT LIKE '%@%@%'
                 AND e.email NOT LIKE '@%'
                 AND e.email NOT LIKE '%@'
            THEN e.email
            ELSE NULL
        END AS email,

        CASE
            WHEN LENGTH(REGEXP_REPLACE(e.phone, '[^0-9]', '')) >= 10
            THEN REGEXP_REPLACE(e.phone, '[^0-9]', '')
            ELSE NULL
        END AS phone,

        e.salary,

        e.sales_target,

        e.current_sales,

        e.performance_rating,

        e.date_of_birth,

        e.hire_date,

        DATEDIFF(year, e.hire_date, CURRENT_DATE()) AS tenure_years,

        CASE
            WHEN e.sales_target > 0
            THEN (e.current_sales / e.sales_target) * 100
            ELSE NULL
        END AS target_achievement_percentage,

        COALESCE(em.orders_processed, 0) AS orders_processed,

        COALESCE(em.total_sales_amount, 0) AS total_sales_amount,

        e.street,

        e.city,

        e.state,

        e.zip_code,

        e.certifications,

        e.last_modified_date,

        e._source_file,

        e._loaded_at,

        e._batch_id

    FROM employees e

    LEFT JOIN employee_metrics em
        ON e.employee_id = em.employee_id

)

SELECT *
FROM transformed