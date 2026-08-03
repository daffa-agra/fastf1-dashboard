{{ config(materialized='table', schema='gold_f1_db') }}

SELECT
    telemetry_key,
    {{ dbt_utils.generate_surrogate_key(['season','round_number','event_name','session_type']) }} AS session_key,
    {{ dbt_utils.generate_surrogate_key(['car_number','season']) }} AS driver_key,

    season, round_number, event_name, session_type, car_number,
    ts, time_sec, session_time_sec,
    rpm, speed_kmh, gear, throttle_pct, brake, drs, source
FROM {{ ref('silver_telemetry') }}