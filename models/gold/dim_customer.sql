SELECT

    {{ dbt_utils.generate_surrogate_key(['customer_id', 'dbt_valid_from']) }} AS customer_key,

    customer_id,

    full_name,

    email,

    phone,

    full_address,

    street,

    city,

    state,

    country,

    zip_code,

    occupation,

    income_bracket,

    birth_date,

    age,

    age_segment,

    loyalty_tier,

    marketing_opt_in,

    preferred_payment_method,

    preferred_communication,

    registration_date,

    total_spend,

    total_purchases,

    dbt_valid_from AS valid_from,

    dbt_valid_to AS valid_to,

    is_current

FROM {{ ref('stg_customer_transformed') }}