{{ config(materialized='table', schema='gold_f1_db') }}

WITH laps_w AS (
    SELECT
        l.season, l.round_number, l.event_name, l.session_type,
        l.driver_number, l.driver_code, l.team,
        l.lap_number, l.lap_time_sec, l.lap_start_date,
        w.rainfall, w.air_temp, w.track_temp, w.humidity_pct, w.wind_speed_ms
    FROM {{ ref('fact_lap') }} l
    LEFT JOIN {{ ref('silver_weather') }} w
      ON w.time_sec = (
          SELECT MAX(w2.time_sec)
          FROM {{ ref('silver_weather') }} w2
          WHERE w2.time_sec <= l.session_time_sec
      )
)
SELECT
    season, round_number, event_name, session_type,
    rainfall,
    CASE
        WHEN track_temp < 25 THEN 'Cool (<25°C)'
        WHEN track_temp < 35 THEN 'Mild (25–35°C)'
        WHEN track_temp < 45 THEN 'Warm (35–45°C)'
        ELSE 'Hot (>=45°C)'
    END AS track_temp_bucket,
    COUNT(*) AS laps,
    AVG(lap_time_sec) AS avg_lap_sec,
    MIN(lap_time_sec) AS best_lap_sec,
    AVG(air_temp) AS avg_air_temp,
    AVG(track_temp) AS avg_track_temp,
    AVG(humidity_pct) AS avg_humidity,
    AVG(wind_speed_ms) AS avg_wind_speed
FROM laps_w
GROUP BY 1,2,3,4,5,6