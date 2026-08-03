{{ config(materialized='table', schema='gold_f1_db') }}

SELECT
    season, round_number, event_name, session_type,
    driver_number, driver_code, team,
    COUNT(*) AS total_laps_completed,
    MIN(lap_time_sec) AS fastest_lap_sec,
    AVG(lap_time_sec) AS avg_lap_sec,
    MEDIAN(lap_time_sec) AS median_lap_sec,
    STDDEV(lap_time_sec) AS lap_consistency_stddev,
    MAX(speed_fl) AS max_speed_fl,
    MAX(speed_st) AS max_speed_st,
    COUNT(DISTINCT stint) AS total_stints,
    MIN(position) AS best_position,
    MAX(position) AS worst_position,
    SUM(CASE WHEN is_personal_best THEN 1 ELSE 0 END) AS personal_best_laps,
    SUM(CASE WHEN fastest_lap_rank_in_session = 1 THEN 1 ELSE 0 END) AS fastest_laps_in_session
FROM {{ ref('fact_lap') }}
GROUP BY 1,2,3,4,5,6,7