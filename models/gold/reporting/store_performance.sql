WITH sales AS (

    SELECT *
    FROM {{ ref('fact_sales') }}

),

stores AS (

    SELECT *
    FROM {{ ref('dim_store') }}

)

SELECT

    st.store_name,

    st.region,

    COUNT(DISTINCT s.order_id) AS total_orders,

    SUM(s.quantity_sold) AS quantity_sold,

    ROUND(SUM(s.gross_sales_amount),2) AS total_sales,

    ROUND(SUM(s.profit_amount),2) AS total_profit,

    ROUND(AVG(s.gross_sales_amount),2) AS average_order_value

FROM sales s

JOIN stores st
ON s.store_key = st.store_key

GROUP BY

    st.store_name,
    st.region

ORDER BY total_sales DESC