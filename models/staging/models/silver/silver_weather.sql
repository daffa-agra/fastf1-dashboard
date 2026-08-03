{{ config(materialized='table', schema='silver_f1_db') }}

WITH src AS (
    SELECT * FROM {{ source('bronze_f1', 'weather') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['Time']) }} AS weather_key,
    "Time"                                       AS time_raw,
    {{ parse_timedelta_seconds('"Time"') }}         AS time_sec,
    CAST(AirTemp        AS DOUBLE) AS air_temp,
    CAST(Humidity      AS DOUBLE) AS humidity_pct,
    CAST(Pressure      AS DOUBLE) AS pressure_hpa,
    CAST(Rainfall      AS BOOLEAN) AS rainfall,
    CAST(TrackTemp     AS DOUBLE) AS track_temp,
    CAST(WindDirection AS INTEGER) AS wind_direction_deg,
    CAST(WindSpeed     AS DOUBLE) AS wind_speed_ms,
    CURRENT_TIMESTAMP AS _loaded_at
FROM src
WHERE "Time" IS NOT NULL