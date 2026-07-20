SELECT

    customer_segment_impact,

    COUNT(DISTINCT customer_key) AS customers,

    SUM(line_revenue) AS sales,

    SUM(profit_amount) AS profit

FROM {{ ref('fact_sales') }}

GROUP BY customer_segment_impact