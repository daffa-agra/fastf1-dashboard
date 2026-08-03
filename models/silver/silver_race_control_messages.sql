{{ config(materialized='table', schema='silver_f1_db') }}

WITH rcm AS (
    SELECT
        "Time" AS time_ts,
        TRIM(Category)  AS category,
        TRIM(Message)   AS message,
        TRIM(Status)    AS status,
        TRIM(Flag)      AS flag,
        TRIM(Scope)     AS scope,
        CAST(Sector AS DOUBLE)        AS sector,
        CAST(RacingNumber AS INTEGER) AS racing_number,
        CAST(Lap AS VARCHAR)          AS lap_raw,
        CAST(Season AS INTEGER)       AS season,
        CAST(RoundNumber AS INTEGER)  AS round_number,
        TRIM(EventName)               AS event_name,
        TRIM(SessionType)             AS session_type
    FROM {{ source('bronze_f1', 'race_control_messages') }}
),

msgs AS (
    SELECT
        "Time" AS time_ts,
        TRIM(Category)  AS category,
        TRIM(Message)   AS message,
        TRIM(Status)    AS status,
        TRIM(Flag)      AS flag,
        TRIM(Scope)     AS scope,
        CAST(Sector AS DOUBLE)        AS sector,
        CAST(RacingNumber AS INTEGER) AS racing_number,
        CAST(Lap AS VARCHAR)          AS lap_raw,
        NULL::INTEGER                 AS season,
        NULL::INTEGER                 AS round_number,
        NULL::VARCHAR                 AS event_name,
        NULL::VARCHAR                 AS session_type
    FROM {{ source('bronze_f1', 'messages') }}
),

combined AS (
    SELECT * FROM rcm
    UNION ALL
    SELECT * FROM msgs
),

cleaned AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['time_ts','category','message','racing_number']) }} AS message_key,
        CAST(time_ts AS TIMESTAMP) AS time_ts,
        category, message, status, flag, scope, sector, racing_number,
        TRY_CAST(LAP_raw AS INTEGER) AS lap,
        season, round_number, event_name, session_type,
        CURRENT_TIMESTAMP AS _loaded_at
    FROM combined
    WHERE time_ts IS NOT NULL
)

SELECT * FROM cleaned
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY message_key ORDER BY time_ts DESC
) = 1