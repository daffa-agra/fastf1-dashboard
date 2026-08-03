{{ config(materialized='table', schema='gold_f1_db') }}

SELECT
    season, round_number, event_name, session_type, team,
    COUNT(DISTINCT driver_number) AS drivers_count,
    COUNT(*) AS laps_completed,
    MIN(lap_time_sec) AS fastest_lap_sec,
    AVG(lap_time_sec) AS avg_lap_sec,
    MAX(speed_fl) AS top_speed_fl,
    SUM(CASE WHEN fastest_lap_rank_in_session = 1 THEN 1 ELSE 0 END) AS fastest_laps_in_session,
    AVG(tyre_life) AS avg_tyre_life_at_lap,
    SUM(CASE WHEN fresh_tyre THEN 1 ELSE 0 END) AS laps_on_fresh_tyres
FROM {{ ref('fact_lap') }}
GROUP BY 1,2,3,4,5