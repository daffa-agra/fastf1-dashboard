{{ config(materialized='table', schema='gold_f1_db') }}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['compound','fresh_tyre']) }} AS tyre_key,
    compound,
    fresh_tyre,
    CASE
        WHEN fresh_tyre THEN 'Fresh'
        ELSE 'Used'
    END AS tyre_state,
    CASE compound
        WHEN 'SOFT' THEN 'Soft (Red)'
        WHEN 'MEDIUM' THEN 'Medium (Yellow)'
        WHEN 'HARD' THEN 'Hard (White)'
        WHEN 'INTERMEDIATE' THEN 'Intermediate (Green)'
        WHEN 'WET' THEN 'Wet (Blue)'
        ELSE compound
    END AS compound_description
FROM {{ ref('silver_laps') }}
WHERE compound IS NOT NULL