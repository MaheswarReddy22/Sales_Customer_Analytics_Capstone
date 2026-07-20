SELECT

    {{ dbt_utils.generate_surrogate_key(['employee_id']) }} AS employee_key,

    employee_id,

    full_name,

    role,

    department,

    work_location,

    employment_status,

    manager_id,

    tenure_years AS tenure,

    email,

    phone,

    salary,

    performance_rating,

    target_achievement_percentage,

    orders_processed,

    total_sales_amount

FROM {{ ref('stg_employees_transformed') }}