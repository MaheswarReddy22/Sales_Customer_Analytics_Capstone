WITH src AS (

    SELECT
        RAW_RECORD,
        _source_file,
        _loaded_at,
        _batch_id
    FROM {{ ref('bronze_orders') }}

),

orders_flattened AS (

    -- first flatten: unwrap the outer orders_data array
    -- one row per order, but order_items is still an unopened array inside it
    SELECT
        VALUE AS order_record,
        _source_file,
        _loaded_at,
        _batch_id
    FROM src,
         LATERAL FLATTEN(INPUT => RAW_RECORD:orders_data)

),

items_flattened AS (

    -- second flatten: unwrap order_items within each order
    -- this is the step that turns 1 order into N rows (one per line item)
    SELECT
        order_record,
        item.value AS item,
        _source_file,
        _loaded_at,
        _batch_id
    FROM orders_flattened,
         LATERAL FLATTEN(INPUT => order_record:order_items) AS item

)

SELECT

    TRIM(order_record:order_id::STRING) AS order_id,

    TRIM(order_record:customer_id::STRING) AS customer_id,

    TRIM(order_record:employee_id::STRING) AS employee_id,

    TRIM(order_record:store_id::STRING) AS store_id,

    TRIM(order_record:campaign_id::STRING) AS campaign_id,

    TRIM(order_record:order_source::STRING) AS order_source,

    TRIM(order_record:order_status::STRING) AS order_status,

    TRIM(order_record:payment_method::STRING) AS payment_method,

    TRIM(order_record:shipping_method::STRING) AS shipping_method,

    order_record:discount_amount::NUMBER(9,6) AS order_discount_amount,

    order_record:shipping_cost::NUMBER(18,2) AS shipping_cost,

    order_record:tax_amount::NUMBER(18,2) AS tax_amount,

    order_record:total_amount::NUMBER(18,2) AS total_amount,

    -- billing_address / shipping_address are nested objects on the order —
    -- only their children become columns, same rule as store/employee address
    TRIM(order_record:billing_address:street::STRING) AS billing_street,

    TRIM(order_record:billing_address:city::STRING) AS billing_city,

    TRIM(order_record:billing_address:state::STRING) AS billing_state,

    TRIM(order_record:billing_address:zip_code::STRING) AS billing_zip_code,

    TRIM(order_record:shipping_address:street::STRING) AS shipping_street,

    TRIM(order_record:shipping_address:city::STRING) AS shipping_city,

    TRIM(order_record:shipping_address:state::STRING) AS shipping_state,

    TRIM(order_record:shipping_address:zip_code::STRING) AS shipping_zip_code,

    -- these come from the inner ITEM object — different for every row
    TRIM(item:product_id::STRING) AS product_id,

    item:quantity::NUMBER AS quantity,

    item:unit_price::NUMBER(18,2) AS unit_price,

    item:cost_price::NUMBER(18,2) AS cost_price,

    item:discount_amount::NUMBER(9,6) AS item_discount_amount,

    -- timestamps are ISO 8601 with a trailing Z (e.g. 2024-04-03T17:49:45Z)
    -- so a straight cast works here — unlike the plain-date fields elsewhere
    order_record:order_date::TIMESTAMP_NTZ AS order_date,

    order_record:created_at::TIMESTAMP_NTZ AS created_at,

    order_record:shipping_date::TIMESTAMP_NTZ AS shipping_date,

    order_record:delivery_date::TIMESTAMP_NTZ AS delivery_date,

    order_record:estimated_delivery_date::TIMESTAMP_NTZ AS estimated_delivery_date,

    _source_file,

    _loaded_at,

    _batch_id

FROM items_flattened