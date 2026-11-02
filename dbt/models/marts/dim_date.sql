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
        explode(sequence(DATE'2024-01-01', DATE'2024-12-31', INTERVAL 1 DAY)) AS d
)