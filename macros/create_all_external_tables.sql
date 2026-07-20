{% macro create_all_external_tables() %}

{% set datasets = [

('CUSTOMERS_EXT','customer_data','.*customers_.*\\.json'),
('ORDERS_EXT','orders_data','.*orders_.*\\.json'),
('PRODUCTS_EXT','product_data','.*products_.*\\.json'),
('STORES_EXT','store_data','.*stores_.*\\.json'),
('EMPLOYEES_EXT','employee_data','.*employees_.*\\.json'),
('SUPPLIERS_EXT','supplier_data','.*suppliers_.*\\.json'),
('CAMPAIGNS_EXT','campaign_data','.*campaigns_.*\\.json')

] %}

{% for table_name, folder_name, file_pattern in datasets %}

{{ create_external_table(
    'RAW',
    'STG_CAPSTONE',
    'FF_JSON',
    table_name,
    folder_name,
    file_pattern
) }}

{% endfor %}

{% endmacro %}