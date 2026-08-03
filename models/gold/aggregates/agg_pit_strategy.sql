{{ config(materialized='table', schema='gold_f1_db') }}

SELECT
    season, round_number, event_name, session_type,
    driver_number, driver_code, team,
    COUNT(DISTINCT stint) AS total_stints,
    COUNT(DISTINCT CASE WHEN pit_in_time_sec IS NOT NULL THEN stint END) AS pit_stops,
    AVG(pit_stop_duration_sec) AS avg_pit_stop_sec,
    MIN(pit_stop_duration_sec) AS fastest_pit_sec,
    MAX(pit_stop_duration_sec) AS slowest_pit_sec,
    AVG(tyre_life) AS avg_stint_length_laps
FROM {{ ref('fact_lap') }}
GROUP BY 1,2,3,4,5,6,7