{{ config(materialized='table', schema='silver_f1_db') }}

WITH src AS (
    SELECT * FROM {{ source('bronze_f1', 'telemetry') }}
),

cleaned AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['Season','RoundNumber','EventName','SessionType','Car','Date']) }} AS telemetry_key,

        CAST(Season      AS INTEGER)  AS season,
        CAST(RoundNumber AS INTEGER)  AS round_number,
        TRIM(EventName)               AS event_name,
        TRIM(SessionType)             AS session_type,
        CAST(Car         AS INTEGER)  AS car_number,
        CAST(Date        AS TIMESTAMP) AS ts,

        CAST(RPM      AS DOUBLE) AS rpm,
        CAST(Speed    AS DOUBLE) AS speed_kmh,
        CAST(nGear    AS INTEGER) AS gear,
        CAST(Throttle AS DOUBLE) AS throttle_pct,
        CAST(Brake    AS BOOLEAN) AS brake,
        CAST(DRS      AS INTEGER) AS drs,
        TRIM(Source)               AS source,

        "Time"        AS time_raw,
        {{ parse_timedelta_seconds('"Time"') }}        AS time_sec,
        "SessionTime" AS session_time_raw,
        {{ parse_timedelta_seconds('"SessionTime"') }} AS session_time_sec,

        CURRENT_TIMESTAMP AS _loaded_at
    FROM src
    WHERE Date IS NOT NULL
      AND Car IS NOT NULL
)

SELECT * FROM cleaned