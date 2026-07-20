SELECT

    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_key,

    product_id,

    name AS product_name,

    product_full_description,

    category,

    subcategory,

    product_hierarchy,

    brand,

    color,

    size,

    dimensions,

    weight,

    warranty_period,

    unit_price,

    cost_price,

    stock_quantity,

    reorder_level,

    supplier_id,

    profit_margin_percentage,

    is_low_stock,

    is_featured

FROM {{ ref('stg_products_transformed') }}