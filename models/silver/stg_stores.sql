WITH src AS (

    SELECT
        RAW_RECORD,
        _source_file,
        _loaded_at,
        _batch_id
    FROM {{ ref('bronze_stores') }}

),

flattened AS (

    SELECT
        VALUE AS store,
        _source_file,
        _loaded_at,
        _batch_id
    FROM src,
         LATERAL FLATTEN(INPUT => RAW_RECORD:stores_data)

),

cleaned AS (

    SELECT

        TRIM(store:store_id::STRING) AS store_id,

        TRIM(store:store_name::STRING) AS store_name,

        TRIM(store:store_type::STRING) AS store_type,

        TRIM(store:region::STRING) AS region,

        LOWER(TRIM(store:email::STRING)) AS email,

        TRIM(store:phone_number::STRING) AS phone_number,

        TRIM(store:manager_id::STRING) AS manager_id,

        store:employee_count::NUMBER AS employee_count,

        store:size_sq_ft::NUMBER AS size_sq_ft,

        store:monthly_rent::NUMBER(18,2) AS monthly_rent,

        store:sales_target::NUMBER(18,2) AS sales_target,

        store:current_sales::NUMBER(18,2) AS current_sales,

        store:is_active::BOOLEAN AS is_active,

        -- address is nested inside 'store' — only its children become columns,
        -- 'address' itself is just a path and is never a column
        TRIM(store:address:street::STRING) AS street,

        TRIM(store:address:city::STRING) AS city,

        TRIM(store:address:state::STRING) AS state,

        TRIM(store:address:country::STRING) AS country,

        TRIM(store:address:zip_code::STRING) AS zip_code,

        -- same idea for operating_hours — walked through, discarded, children survive
        TRIM(store:operating_hours:weekdays::STRING) AS weekday_hours,

        TRIM(store:operating_hours:weekends::STRING) AS weekend_hours,

        TRIM(store:operating_hours:holidays::STRING) AS holiday_hours,

        -- services is a plain list, not a list of objects — leave it as a raw array
        -- (no second flatten needed; nothing in the PDF requires per-service rows)
        store:services AS services,

        COALESCE(
            TRY_TO_DATE(store:opening_date::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(store:opening_date::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(store:opening_date::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(store:opening_date::STRING, 'MM-DD-YYYY')
        ) AS opening_date,

        COALESCE(
            TRY_TO_DATE(store:last_modified_date::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(store:last_modified_date::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(store:last_modified_date::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(store:last_modified_date::STRING, 'MM-DD-YYYY')
        ) AS last_modified_date,

        _source_file,

        _loaded_at,

        _batch_id

    FROM flattened

)

SELECT *
FROM cleaned
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY store_id, last_modified_date
    ORDER BY _loaded_at DESC
) = 1