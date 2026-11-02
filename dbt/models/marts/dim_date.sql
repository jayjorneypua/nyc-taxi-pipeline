WITH bounds AS (
    SELECT
        trunc(CAST(MIN(pickup_at) AS DATE), 'YEAR')                                AS start_date
      , date_add(add_months(trunc(CAST(MAX(pickup_at) AS DATE), 'YEAR'), 12), -1)  AS end_date
    FROM
        {{ ref('stg_trips') }}
)
SELECT
    CAST(date_format(d, 'yyyyMMdd') AS INT)  AS date_key
  , d                                        AS full_date
  , year(d)                                  AS year
  , quarter(d)                               AS quarter
  , month(d)                                 AS month
  , date_format(d, 'MMMM')                   AS month_name
  , day(d)                                   AS day_of_month
  , date_format(d, 'EEEE')                   AS day_name
  , dayofweek(d) IN (1, 7)                   AS is_weekend
FROM (
    SELECT
        explode(sequence(start_date, end_date, INTERVAL 1 DAY)) AS d
    FROM
        bounds
)