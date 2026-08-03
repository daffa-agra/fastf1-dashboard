{{ config(materialized='table', schema='gold_f1_db') }}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['season','round_number','event_name','session_type']) }} AS session_key,
    season,
    round_number,
    event_name,
    session_type,
    CASE
        WHEN session_type = 'R'  THEN 'Race'
        WHEN session_type = 'Q'  THEN 'Qualifying'
        WHEN session_type = 'FP1' THEN 'Free Practice 1'
        WHEN session_type = 'FP2' THEN 'Free Practice 2'
        WHEN session_type = 'FP3' THEN 'Free Practice 3'
        WHEN session_type = 'S'  THEN 'Sprint'
        WHEN session_type = 'SQ' THEN 'Sprint Qualifying'
        ELSE session_type
    END AS session_description
FROM {{ ref('silver_laps') }}