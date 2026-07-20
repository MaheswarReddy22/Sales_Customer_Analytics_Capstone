WITH src AS (

    SELECT
        RAW_RECORD,
        _source_file,
        _loaded_at,
        _batch_id
    FROM {{ ref('bronze_employees') }}

),

flattened AS (

    SELECT
        VALUE AS employee,
        _source_file,
        _loaded_at,
        _batch_id
    FROM src,
         LATERAL FLATTEN(INPUT => RAW_RECORD:employees_data)

),

cleaned AS (

    SELECT

        TRIM(employee:employee_id::STRING) AS employee_id,

        INITCAP(TRIM(employee:first_name::STRING)) AS first_name,

        INITCAP(TRIM(employee:last_name::STRING)) AS last_name,

        LOWER(TRIM(employee:email::STRING)) AS email,

        TRIM(employee:phone::STRING) AS phone,

        TRIM(employee:role::STRING) AS role,

        TRIM(employee:department::STRING) AS department,

        TRIM(employee:education::STRING) AS education,

        TRIM(employee:employment_status::STRING) AS employment_status,

        TRIM(employee:manager_id::STRING) AS manager_id,

        TRIM(employee:work_location::STRING) AS work_location,

        employee:salary::NUMBER(18,2) AS salary,

        employee:sales_target::NUMBER(18,2) AS sales_target,

        employee:current_sales::NUMBER(18,2) AS current_sales,

        employee:performance_rating::NUMBER(3,1) AS performance_rating,

        -- address nested object — only children become columns
        TRIM(employee:address:street::STRING) AS street,

        TRIM(employee:address:city::STRING) AS city,

        TRIM(employee:address:state::STRING) AS state,

        TRIM(employee:address:zip_code::STRING) AS zip_code,

        -- certifications is a plain list, left as raw array — no second flatten needed
        employee:certifications AS certifications,

        COALESCE(
            TRY_TO_DATE(employee:date_of_birth::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(employee:date_of_birth::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(employee:date_of_birth::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(employee:date_of_birth::STRING, 'MM-DD-YYYY')
        ) AS date_of_birth,

        COALESCE(
            TRY_TO_DATE(employee:hire_date::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(employee:hire_date::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(employee:hire_date::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(employee:hire_date::STRING, 'MM-DD-YYYY')
        ) AS hire_date,

        COALESCE(
            TRY_TO_DATE(employee:last_modified_date::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(employee:last_modified_date::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(employee:last_modified_date::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(employee:last_modified_date::STRING, 'MM-DD-YYYY')
        ) AS last_modified_date,

        _source_file,

        _loaded_at,

        _batch_id

    FROM flattened

)

SELECT *
FROM cleaned
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY employee_id, last_modified_date
    ORDER BY _loaded_at DESC
) = 1