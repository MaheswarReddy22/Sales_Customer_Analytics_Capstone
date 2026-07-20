WITH products AS (

    SELECT *
    FROM {{ ref('stg_products') }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY product_id
        ORDER BY last_modified_date DESC
    ) = 1

),

transformed AS (

    SELECT

        product_id,

        INITCAP(name) AS name,

        INITCAP(name) || ' - ' || short_description || ' (' || technical_specs || ')' AS product_full_description,

        INITCAP(category) AS category,

        INITCAP(subcategory) AS subcategory,

        INITCAP(brand) AS brand,

        INITCAP(category)
        || ' > ' ||
        INITCAP(subcategory)
        || ' > ' ||
        INITCAP(brand) AS product_hierarchy,

        color,

        size,

        dimensions,

        weight,

        warranty_period,

        supplier_id,

        cost_price,

        unit_price,

        stock_quantity,

        reorder_level,

        CASE
            WHEN unit_price > 0
            THEN ((unit_price - cost_price) / unit_price) * 100
            ELSE NULL
        END AS profit_margin_percentage,

        CASE
            WHEN stock_quantity < reorder_level
            THEN TRUE
            ELSE FALSE
        END AS is_low_stock,

        is_featured,

        launch_date,

        last_modified_date,

        _source_file,

        _loaded_at,

        _batch_id

    FROM products

)

SELECT * FROM transformed