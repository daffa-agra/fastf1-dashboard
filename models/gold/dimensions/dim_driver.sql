{{ config(materialized='table', schema='gold_f1_db') }}

WITH base AS (
    SELECT DISTINCT
        driver_number,
        driver_code,
        team,
        season
    FROM {{ ref('silver_laps') }}
    WHERE driver_number IS NOT NULL
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['driver_number','season']) }} AS driver_key,
    driver_number,
    driver_code,
    team,
    season,
    CURRENT_TIMESTAMP AS _loaded_at
FROM base