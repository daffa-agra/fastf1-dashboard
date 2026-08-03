{{ config(materialized='table', schema='gold_f1_db') }}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['season','round_number','event_name']) }} AS event_key,
    season,
    round_number,
    event_name
FROM {{ ref('silver_laps') }}
WHERE season IS NOT NULL AND round_number IS NOT NULL