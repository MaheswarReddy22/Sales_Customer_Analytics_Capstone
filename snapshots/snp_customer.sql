{% snapshot snp_customer %}

{{
    config(
        target_schema='SILVER',
        unique_key='customer_id',
        strategy='timestamp',
        updated_at='snapshot_updated_at'
    )
}}

SELECT
    *,
    CAST(last_modified_date AS TIMESTAMP_NTZ) AS snapshot_updated_at
FROM {{ ref('stg_customers') }}

{% endsnapshot %}