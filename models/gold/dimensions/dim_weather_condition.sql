{{ config(materialized='table', schema='gold_f1_db') }}

WITH base AS (
    SELECT
        rainfall AS rainfall_flag,
        track_temp,
        air_temp,
        CASE
            WHEN track_temp < 25 THEN 'Cool (<25°C)'
            WHEN track_temp < 35 THEN 'Mild (25–35°C)'
            WHEN track_temp < 45 THEN 'Warm (35–45°C)'
            WHEN track_temp >= 45 THEN 'Hot (>=45°C)'
            ELSE 'Unknown'
        END AS track_temp_bucket,
        CASE
            WHEN air_temp < 15 THEN 'Cold (<15°C)'
            WHEN air_temp < 22 THEN 'Cool (15–22°C)'
            WHEN air_temp < 28 THEN 'Warm (22–28°C)'
            ELSE 'Hot (>=28°C)'
        END AS air_temp_bucket
    FROM {{ ref('silver_weather') }}
    WHERE track_temp IS NOT NULL
)
SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['rainfall_flag','track_temp_bucket']) }} AS weather_condition_key,
    rainfall_flag,
    track_temp_bucket,
    air_temp_bucket
FROM base