WITH date_spine AS (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2024-04-01' as date)",
        end_date="cast('2024-09-28' as date)"
    ) }}

),

enriched AS (

    SELECT

        date_day AS full_date,

        TO_NUMBER(TO_CHAR(date_day, 'YYYYMMDD')) AS date_key,

        YEAR(date_day) AS year,

        QUARTER(date_day) AS quarter,

        MONTH(date_day) AS month,

        MONTHNAME(date_day) AS month_name,

        WEEKOFYEAR(date_day) AS week,

        DAYOFWEEK(date_day) AS day_of_week_number,

        DAYNAME(date_day) AS day_of_week,

        DAY(date_day) AS day_of_month,

        CASE
            WHEN DAYOFWEEK(date_day) IN (0, 6)
            THEN TRUE
            ELSE FALSE
        END AS is_weekend,

        CASE
            WHEN date_day = DATE '2024-05-27' THEN TRUE
            WHEN date_day = DATE '2024-06-19' THEN TRUE
            WHEN date_day = DATE '2024-07-04' THEN TRUE
            WHEN date_day = DATE '2024-09-02' THEN TRUE
            ELSE FALSE
        END AS is_holiday,

        CASE
            WHEN MONTH(date_day) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(date_day) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(date_day) IN (9, 10, 11) THEN 'Fall'
            ELSE 'Winter'
        END AS season

    FROM date_spine

)

SELECT *
FROM enriched