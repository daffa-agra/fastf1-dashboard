{{ config(materialized='table', schema='gold_f1_db') }}

SELECT
    message_key,
    {{ dbt_utils.generate_surrogate_key(['season','round_number','event_name','session_type']) }} AS session_key,
    {{ dbt_utils.generate_surrogate_key(['racing_number','season']) }} AS driver_key,
    time_ts, category, message, status, flag, scope,
    sector, racing_number, lap, season, round_number, event_name, session_type
FROM {{ ref('silver_race_control_messages') }}