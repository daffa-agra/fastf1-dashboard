{{ config(materialized='table', schema='gold_f1_db') }}

SELECT
    season, round_number, event_name, session_type, car_number,
    COUNT(*) AS samples,
    SUM(CASE WHEN drs >= 8 THEN 1 ELSE 0 END) AS drs_active_samples,
    SUM(CASE WHEN drs >= 8 THEN 1 ELSE 0 END)::DOUBLE / COUNT(*) AS drs_active_pct,
    AVG(CASE WHEN drs >= 8 THEN speed_kmh END) AS avg_speed_with_drs,
    AVG(CASE WHEN drs < 8 THEN speed_kmh END) AS avg_speed_without_drs,
    AVG(CASE WHEN drs >= 8 THEN throttle_pct END) AS avg_throttle_with_drs
FROM {{ ref('fact_telemetry') }}
GROUP BY 1,2,3,4,5