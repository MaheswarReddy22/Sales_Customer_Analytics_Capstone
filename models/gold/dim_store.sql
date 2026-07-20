SELECT

    {{ dbt_utils.generate_surrogate_key(['store_id']) }} AS store_key,

    store_id,

    store_name,

    full_address AS address,

    region,

    store_type,

    opening_date,

    size_category,

    employee_count,

    sales_target_achievement_percentage,

    revenue_per_sq_ft,

    employee_efficiency,

    has_performance_issue

FROM {{ ref('stg_stores_transformed') }}