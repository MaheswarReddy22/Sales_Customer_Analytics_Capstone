WITH src AS (

    SELECT
        RAW_RECORD,
        _source_file,
        _loaded_at,
        _batch_id
    FROM {{ ref('bronze_customers') }}

),

flattened AS (

    SELECT
        VALUE AS customer,
        _source_file,
        _loaded_at,
        _batch_id
    FROM src,
         LATERAL FLATTEN(INPUT => RAW_RECORD:customers_data)

),

cleaned AS (

    SELECT

        TRIM(customer:customer_id::STRING) AS customer_id,

        TRIM(customer:first_name::STRING) AS first_name,

        TRIM(customer:last_name::STRING) AS last_name,

        customer:email::STRING AS email,

        customer:phone::STRING AS phone,

        customer:occupation::STRING AS occupation,

        customer:income_bracket::STRING AS income_bracket,

        customer:loyalty_tier::STRING AS loyalty_tier,

        customer:preferred_payment_method::STRING AS preferred_payment_method,

        customer:preferred_communication::STRING AS preferred_communication,

        customer:marketing_opt_in::BOOLEAN AS marketing_opt_in,

        -- birth_date: source has mixed formats (YYYY-MM-DD, MM/DD/YYYY, DD-MM-YYYY, MM-DD-YYYY, null)
        -- TRY_TO_DATE returns NULL instead of erroring when a pattern doesn't match,
        -- so we try each known format in order until one succeeds.
        COALESCE(
            TRY_TO_DATE(customer:birth_date::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(customer:birth_date::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(customer:birth_date::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(customer:birth_date::STRING, 'MM-DD-YYYY')
        ) AS birth_date,

        COALESCE(
            TRY_TO_DATE(customer:registration_date::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(customer:registration_date::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(customer:registration_date::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(customer:registration_date::STRING, 'MM-DD-YYYY')
        ) AS registration_date,

        COALESCE(
            TRY_TO_DATE(customer:last_purchase_date::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(customer:last_purchase_date::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(customer:last_purchase_date::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(customer:last_purchase_date::STRING, 'MM-DD-YYYY')
        ) AS last_purchase_date,

        COALESCE(
            TRY_TO_DATE(customer:last_modified_date::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(customer:last_modified_date::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(customer:last_modified_date::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(customer:last_modified_date::STRING, 'MM-DD-YYYY')
        ) AS last_modified_date,

        customer:total_spend::NUMBER(18,2) AS total_spend,

        customer:total_purchases::NUMBER AS total_purchases,

        customer:address:street::STRING AS street,

        customer:address:city::STRING AS city,

        customer:address:state::STRING AS state,

        customer:address:country::STRING AS country,

        customer:address:zip_code::STRING AS zip_code,

        _source_file,

        _loaded_at,

        _batch_id

    FROM flattened

)

SELECT *
FROM cleaned
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY
        last_modified_date DESC,
        _loaded_at DESC
) = 1