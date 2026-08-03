{% macro parse_timedelta_seconds(col) %}
  CASE
    WHEN {{ col }} IS NULL OR TRIM({{ col }}) = '' THEN NULL
    WHEN {{ col }} LIKE '% days %' THEN
        CAST(SPLIT_PART({{ col }}, ' days ', 1) AS DOUBLE) * 86400
      + TRY_CAST(SPLIT_PART(SPLIT_PART({{ col }}, ' days ', 2), ':', 1) AS DOUBLE) * 3600
      + TRY_CAST(SPLIT_PART(SPLIT_PART({{ col }}, ' days ', 2), ':', 2) AS DOUBLE) * 60
      + TRY_CAST(SPLIT_PART(SPLIT_PART({{ col }}, ' days ', 2), ':', 3) AS DOUBLE)
    ELSE
        TRY_CAST(SPLIT_PART({{ col }}, ':', 1) AS DOUBLE) * 3600
      + TRY_CAST(SPLIT_PART({{ col }}, ':', 2) AS DOUBLE) * 60
      + TRY_CAST(SPLIT_PART({{ col }}, ':', 3) AS DOUBLE)
  END
{% endmacro %}