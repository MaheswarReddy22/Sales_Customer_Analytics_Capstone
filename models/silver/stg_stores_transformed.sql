WITH stores AS (

    SELECT *
    FROM {{ ref('stg_stores') }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY store_id
        ORDER BY last_modified_date DESC, _loaded_at DESC
    ) = 1

),

transformed AS (

    SELECT

        store_id,
        INITCAP(store_name) AS store_name,
        INITCAP(store_type) AS store_type,
        INITCAP(region) AS region,

        street,
        city,
        state,
        country,

        zip_code,

        CONCAT(street, ', ', city, ', ', state, ', ', country, ' ', zip_code) AS full_address,

        email,

        phone_number,

        manager_id,
        employee_count,
        size_sq_ft,

        CASE
            WHEN size_sq_ft < 5000 THEN 'Small'
            WHEN size_sq_ft <= 10000 THEN 'Medium'
            ELSE 'Large'
        END AS size_category,

        monthly_rent,
        sales_target,
        current_sales,

        opening_date,

        DATEDIFF('year', opening_date, CURRENT_DATE()) AS store_age_years,

        CASE
            WHEN sales_target > 0
            THEN ROUND((current_sales / sales_target) * 100, 2)
            ELSE NULL
        END AS sales_target_achievement_percentage,

        CASE
            WHEN size_sq_ft > 0
            THEN ROUND(current_sales / size_sq_ft, 2)
            ELSE NULL
        END AS revenue_per_sq_ft,

        CASE
            WHEN employee_count > 0
            THEN ROUND(current_sales / employee_count, 2)
            ELSE NULL
        END AS employee_efficiency,

        CASE
            WHEN sales_target > 0
                 AND (current_sales / sales_target) * 100 < 90
            THEN TRUE
            ELSE FALSE
        END AS has_performance_issue,

        is_active,
        weekday_hours,
        weekend_hours,
        holiday_hours,
        services,
        last_modified_date,
        _source_file,
        _loaded_at,
        _batch_id

    FROM stores

)

SELECT *
FROM transformed