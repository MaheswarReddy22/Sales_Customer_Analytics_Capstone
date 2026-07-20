WITH src AS (

    SELECT
        RAW_RECORD,
        _source_file,
        _loaded_at,
        _batch_id
    FROM {{ ref('bronze_products') }}

),

flattened AS (

    SELECT
        VALUE AS product,
        _source_file,
        _loaded_at,
        _batch_id
    FROM src,
         LATERAL FLATTEN(INPUT => RAW_RECORD:products_data)

),

cleaned AS (

    SELECT

        TRIM(product:product_id::STRING) AS product_id,

        TRIM(product:name::STRING) AS name,

        TRIM(product:brand::STRING) AS brand,

        TRIM(product:category::STRING) AS category,

        TRIM(product:subcategory::STRING) AS subcategory,

        TRIM(product:product_line::STRING) AS product_line,

        TRIM(product:short_description::STRING) AS short_description,

        TRIM(product:technical_specs::STRING) AS technical_specs,

        TRIM(product:color::STRING) AS color,

        TRIM(product:size::STRING) AS size,

        TRIM(product:dimensions::STRING) AS dimensions,

        TRIM(product:weight::STRING) AS weight,

        TRIM(product:warranty_period::STRING) AS warranty_period,

        TRIM(product:supplier_id::STRING) AS supplier_id,

        product:cost_price::NUMBER(18,2) AS cost_price,

        product:unit_price::NUMBER(18,2) AS unit_price,

        product:stock_quantity::NUMBER AS stock_quantity,

        product:reorder_level::NUMBER AS reorder_level,

        product:is_featured::BOOLEAN AS is_featured,

        COALESCE(
            TRY_TO_DATE(product:launch_date::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(product:launch_date::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(product:launch_date::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(product:launch_date::STRING, 'MM-DD-YYYY')
        ) AS launch_date,

        COALESCE(
            TRY_TO_DATE(product:last_modified_date::STRING, 'YYYY-MM-DD'),
            TRY_TO_DATE(product:last_modified_date::STRING, 'MM/DD/YYYY'),
            TRY_TO_DATE(product:last_modified_date::STRING, 'DD-MM-YYYY'),
            TRY_TO_DATE(product:last_modified_date::STRING, 'MM-DD-YYYY')
        ) AS last_modified_date,

        _source_file,

        _loaded_at,

        _batch_id

    FROM flattened

)

SELECT *
FROM cleaned
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY product_id, last_modified_date
    ORDER BY _loaded_at DESC
) = 1