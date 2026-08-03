{{ config(materialized='table', schema='gold_f1_db') }}

SELECT
    season, round_number, event_name, session_type,
    driver_number, driver_code, team,
    MAX(speed_fl) AS max_speed_fl,
    MAX(speed_st) AS max_speed_st,
    MAX(speed_i1) AS max_speed_i1,
    MAX(speed_i2) AS max_speed_i2,
    AVG(speed_fl) AS avg_speed_fl,
    AVG(speed_st) AS avg_speed_st,
    RANK() OVER (PARTITION BY season, round_number, event_name, session_type ORDER BY MAX(speed_fl) DESC) AS speed_fl_rank
FROM {{ ref('fact_lap') }}
GROUP BY 1,2,3,4,5,6,7