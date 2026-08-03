{{ config(materialized='table', schema='gold_f1_db') }}

SELECT
    season, round_number, event_name, session_type,
    driver_number, driver_code, team,
    AVG(sector1_time_sec) AS avg_sector1_sec,
    MIN(sector1_time_sec) AS best_sector1_sec,
    AVG(sector2_time_sec) AS avg_sector2_sec,
    MIN(sector2_time_sec) AS best_sector2_sec,
    AVG(sector3_time_sec) AS avg_sector3_sec,
    MIN(sector3_time_sec) AS best_sector3_sec,
    (sector1_time_sec + sector2_time_sec + sector3_time_sec) AS theoretical_best_sec
FROM {{ ref('fact_lap') }}
GROUP BY 1,2,3,4,5,6,7