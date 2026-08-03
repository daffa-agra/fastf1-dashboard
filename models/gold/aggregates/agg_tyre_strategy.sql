{{ config(materialized='table', schema='gold_f1_db') }}

SELECT
    season, round_number, event_name, session_type,
    driver_number, driver_code, team,
    compound, fresh_tyre,
    MIN(stint) AS first_stint_no,
    MAX(stint) AS last_stint_no,
    COUNT(DISTINCT stint) AS stints_on_compound,
    COUNT(*) AS laps_on_compound,
    MIN(lap_number) AS first_lap_on_compound,
    MAX(lap_number) AS last_lap_on_compound,
    MAX(tyre_life) AS max_tyre_life,
    AVG(lap_time_sec) AS avg_lap_sec,
    MIN(lap_time_sec) AS best_lap_sec,
    AVG(speed_fl) AS avg_speed_fl
FROM {{ ref('fact_lap') }}
GROUP BY 1,2,3,4,5,6,7,8,9