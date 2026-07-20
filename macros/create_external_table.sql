{% macro create_external_table(
        schema_name,
        stage_name,
        file_format,
        table_name,
        folder_name,
        file_pattern
) %}

{% set sql %}

CREATE OR REPLACE EXTERNAL TABLE {{ schema_name }}.{{ table_name }}

WITH LOCATION = @{{ schema_name }}.{{ stage_name }}/Capstone_Project_Data/{{ folder_name }}/

FILE_FORMAT = (
    FORMAT_NAME = {{ schema_name }}.{{ file_format }}
)

PATTERN = '{{ file_pattern }}'

AUTO_REFRESH = FALSE;

{% endset %}

{{ log("Creating External Table : " ~ table_name, info=True) }}

{% do run_query(sql) %}

{% endmacro %}