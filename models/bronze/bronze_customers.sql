{{ config(
    unique_key='_source_file'
) }}

SELECT

    VALUE AS RAW_RECORD,

    METADATA$FILENAME AS _source_file,

    CURRENT_TIMESTAMP() AS _loaded_at,

    '{{ invocation_id }}' AS _batch_id

FROM {{ source('raw','CUSTOMERS_EXT') }}

{% if is_incremental() %}

WHERE NOT EXISTS (

    SELECT 1
    FROM {{ this }} t
    WHERE t._source_file = METADATA$FILENAME

)

{% endif %}