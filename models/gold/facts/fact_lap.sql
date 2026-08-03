{{ config(materialized='table', schema='gold_f1_db') }}

WITH laps AS (SELECT * FROM {{ ref('silver_laps') }})

SELECT
    lap_key,
    {{ dbt_utils.generate_surrogate_key(['season','round_number','event_name','session_type']) }} AS session_key,
    {{ dbt_utils.generate_surrogate_key(['driver_number','season']) }} AS driver_key,
    {{ dbt_utils.generate_surrogate_key(['team']) }} AS team_key,
    {{ dbt_utils.generate_surrogate_key(['season','round_number','event_name']) }} AS event_key,
    {{ dbt_utils.generate_surrogate_key(['compound','fresh_tyre']) }} AS tyre_key,

    season, round_number, event_name, session_type,
    driver_number, driver_code, team,
    lap_number, stint, lap_start_date,

    lap_time_sec,
    session_time_sec,  -- ADDED THIS LINE
    sector1_time_sec, sector2_time_sec, sector3_time_sec,
    speed_i1, speed_i2, speed_fl, speed_st,

    compound, tyre_life, fresh_tyre,
    track_status, position, deleted, deleted_reason,
    is_personal_best, is_accurate,

    pit_in_time_sec, pit_out_time_sec,
    COALESCE(
        CASE WHEN pit_in_time_sec IS NOT NULL AND pit_out_time_sec IS NOT NULL
             THEN pit_in_time_sec - LAG(pit_out_time_sec) OVER (
                PARTITION BY season, round_number, event_name, session_type, driver_number
                ORDER BY lap_number)
        END,
        CASE WHEN pit_in_time_sec IS NOT NULL AND pit_out_time_sec IS NULL
             THEN pit_in_time_sec
        END
    ) AS pit_stop_duration_sec,

    ROW_NUMBER() OVER (
        PARTITION BY season, round_number, event_name, session_type, driver_number
        ORDER BY lap_number
    ) AS lap_seq,

    CASE WHEN lap_time_sec IS NOT NULL
         THEN RANK() OVER (
            PARTITION BY season, round_number, event_name, session_type
            ORDER BY lap_time_sec)
         ELSE NULL END AS fastest_lap_rank_in_session
FROM laps
WHERE is_accurate = TRUE
  AND deleted = FALSE
  AND lap_time_sec IS NOT NULL