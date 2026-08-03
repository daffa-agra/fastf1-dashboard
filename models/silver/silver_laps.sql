{{ config(materialized='table', schema='silver_f1_db') }}

WITH src AS (
    SELECT * FROM {{ source('bronze_f1', 'laps') }}
),

cleaned AS (
    SELECT
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['Season','RoundNumber','EventName','SessionType','DriverNumber','LapNumber']) }} AS lap_key,

        -- Context
        CAST(Season         AS INTEGER)        AS season,
        CAST(RoundNumber    AS INTEGER)        AS round_number,
        TRIM(EventName)                          AS event_name,
        TRIM(SessionType)                        AS session_type,
        CAST(DriverNumber   AS INTEGER)        AS driver_number,
        TRIM(Driver)                             AS driver_code,
        TRIM(Team)                               AS team,

        -- Lap identifiers
        CAST(LapNumber AS INTEGER)              AS lap_number,
        CAST(Stint     AS INTEGER)              AS stint,
        CAST(LapStartDate AS TIMESTAMP)         AS lap_start_date,

        -- Time fields (raw + parsed seconds)
        "Time"                                       AS session_time_raw,
        {{ parse_timedelta_seconds('"Time"') }}       AS session_time_sec,
        "LapTime"                                    AS lap_time_raw,
        COALESCE(LapTimeSeconds, {{ parse_timedelta_seconds('"LapTime"') }}) AS lap_time_sec,
        "LapStartTime"                               AS lap_start_time_raw,
        {{ parse_timedelta_seconds('"LapStartTime"') }} AS lap_start_time_sec,
        "PitOutTime"                                 AS pit_out_time_raw,
        {{ parse_timedelta_seconds('"PitOutTime"') }}  AS pit_out_time_sec,
        "PitInTime"                                   AS pit_in_time_raw,
        {{ parse_timedelta_seconds('"PitInTime"') }}   AS pit_in_time_sec,

        "Sector1Time"                                AS sector1_time_raw,
        {{ parse_timedelta_seconds('"Sector1Time"') }}       AS sector1_time_sec,
        "Sector2Time"                                AS sector2_time_raw,
        {{ parse_timedelta_seconds('"Sector2Time"') }}       AS sector2_time_sec,
        "Sector3Time"                                AS sector3_time_raw,
        {{ parse_timedelta_seconds('"Sector3Time"') }}       AS sector3_time_sec,

        "Sector1SessionTime"                        AS sector1_session_time_raw,
        {{ parse_timedelta_seconds('"Sector1SessionTime"') }} AS sector1_session_time_sec,
        "Sector2SessionTime"                        AS sector2_session_time_raw,
        {{ parse_timedelta_seconds('"Sector2SessionTime"') }} AS sector2_session_time_sec,
        "Sector3SessionTime"                        AS sector3_session_time_raw,
        {{ parse_timedelta_seconds('"Sector3SessionTime"') }} AS sector3_session_time_sec,

        -- Speed traps
        CAST(SpeedI1 AS DOUBLE) AS speed_i1,
        CAST(SpeedI2 AS DOUBLE) AS speed_i2,
        CAST(SpeedFL AS DOUBLE) AS speed_fl,
        CAST(SpeedST AS DOUBLE) AS speed_st,

        -- Tyre
        TRIM(Compound)         AS compound,
        CAST(TyreLife AS DOUBLE) AS tyre_life,
        CAST(FreshTyre AS BOOLEAN) AS fresh_tyre,

        -- Race status
        CAST(TrackStatus AS INTEGER) AS track_status,
        CAST(Position AS INTEGER) AS position,
        CAST(Deleted AS BOOLEAN) AS deleted,
        TRIM(DeletedReason) AS deleted_reason,
        CAST(IsPersonalBest AS BOOLEAN) AS is_personal_best,
        CAST(IsAccurate AS BOOLEAN) AS is_accurate,
        CAST(FastF1Generated AS BOOLEAN) AS fastf1_generated,

        -- Loaded_at
        CURRENT_TIMESTAMP AS _loaded_at
    FROM src
    WHERE LapNumber IS NOT NULL
      AND DriverNumber IS NOT NULL
),

deduped AS (
    SELECT *
    FROM cleaned
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY season, round_number, event_name, session_type, driver_number, lap_number
        ORDER BY lap_start_date DESC NULLS LAST
    ) = 1
)

SELECT * FROM deduped