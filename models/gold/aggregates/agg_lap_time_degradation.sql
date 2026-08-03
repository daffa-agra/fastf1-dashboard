{{ config(materialized='table', schema='gold_f1_db') }}

SELECT
    season, round_number, event_name, session_type,
    driver_number, driver_code, team,
    compound, stint,
    MIN(lap_number) AS first_lap_in_stint,
    MAX(lap_number) AS last_lap_in_stint,
    COUNT(*) AS laps_in_stint,
    MIN(lap_time_sec) AS fastest_lap_in_stint,
    MAX(lap_time_sec) AS slowest_lap_in_stint,
    AVG(lap_time_sec) AS avg_lap_in_stint,
    MAX(lap_time_sec) - MIN(lap_time_sec) AS degradation_sec,
    AVG(tyre_life) AS avg_tyre_life,
    (MAX(lap_time_sec) - MIN(lap_time_sec)) / NULLIF(COUNT(*)-1, 0) AS avg_degradation_per_lap_sec
FROM {{ ref('fact_lap') }}
GROUP BY 1,2,3,4,5,6,7,8,9