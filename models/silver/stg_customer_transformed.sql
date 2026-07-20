WITH current_customers AS (

    SELECT *
    FROM {{ ref('snp_customer') }}
    WHERE dbt_valid_to IS NULL
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY last_modified_date DESC, dbt_valid_from DESC
    ) = 1

),

transformed AS (

    SELECT

        customer_id,

        first_name || ' ' || last_name AS full_name,

        first_name,

        last_name,

        CASE
            WHEN email LIKE '%@%.%'
                 AND email NOT LIKE '%@%@%'
                 AND email NOT LIKE '@%'
                 AND email NOT LIKE '%@'
            THEN email
            ELSE NULL
        END AS email,

        CASE
            WHEN LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) >= 10
            THEN REGEXP_REPLACE(phone, '[^0-9]', '')
            ELSE NULL
        END AS phone,

        occupation,

        income_bracket,

        loyalty_tier,

        preferred_payment_method,

        preferred_communication,

        marketing_opt_in,

        birth_date,

        DATEDIFF(year, birth_date, CURRENT_DATE()) AS age,

        CASE
            WHEN DATEDIFF(year, birth_date, CURRENT_DATE()) BETWEEN 18 AND 35 THEN 'Young'
            WHEN DATEDIFF(year, birth_date, CURRENT_DATE()) BETWEEN 36 AND 55 THEN 'Middle-aged'
            WHEN DATEDIFF(year, birth_date, CURRENT_DATE()) >= 56 THEN 'Senior'
            ELSE NULL
        END AS age_segment,

        registration_date,

        last_purchase_date,

        total_spend,

        total_purchases,

        street || ', ' || city || ', ' || state || ' ' || zip_code AS full_address,

        street,

        city,

        state,

        country,

        zip_code,

        last_modified_date,

        _source_file,

        _loaded_at,

        _batch_id,

        dbt_valid_from,

        dbt_valid_to,

        TRUE AS is_current

    FROM current_customers

)

SELECT * FROM transformed