{{ config(materialized='table', schema='gold_f1_db') }}

SELECT
    season, round_number, event_name, session_type, car_number,
    COUNT(*) AS telemetry_samples,
    AVG(rpm) AS avg_rpm,
    MAX(rpm) AS max_rpm,
    AVG(speed_kmh) AS avg_speed_kmh,
    MAX(speed_kmh) AS max_speed_kmh,
    AVG(throttle_pct) AS avg_throttle_pct,
    SUM(CASE WHEN brake THEN 1 ELSE 0 END)::DOUBLE / COUNT(*) AS brake_apply_ratio,
    AVG(drs) AS avg_drs_state,
    SUM(CASE WHEN drs >= 8 THEN 1 ELSE 0 END)::DOUBLE / COUNT(*) AS drs_active_ratio
FROM {{ ref('fact_telemetry') }}
GROUP BY 1,2,3,4,5