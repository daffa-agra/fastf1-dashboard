{{ config(materialized='table', schema='gold_f1_db') }}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['team']) }} AS team_key,
    team
FROM {{ ref('silver_laps') }}
WHERE team IS NOT NULL AND team <> ''