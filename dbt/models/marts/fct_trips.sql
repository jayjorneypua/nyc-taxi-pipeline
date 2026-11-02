SELECT
    {{ dbt_utils.generate_surrogate_key([
        't.vendor_id'
      , 't.pickup_at'
      , 't.dropoff_at'
      , 't.pickup_location_id'
      , 't.dropoff_location_id'
      , 't.total_amount'
    ]) }}                                             AS trip_key
  , CAST(date_format(t.pickup_at, 'yyyyMMdd') AS INT) AS pickup_date_key
  , pl.location_key                                   AS pickup_location_key
  , dl.location_key                                   AS dropoff_location_key
  , t.vendor_id
  , t.payment_type
  , t.rate_code_id
  , t.pickup_at
  , t.dropoff_at
  , (unix_timestamp(t.dropoff_at) - unix_timestamp(t.pickup_at)) / 60.0 AS trip_minutes
  , t.passenger_count
  , t.trip_distance
  , t.fare_amount
  , t.tip_amount
  , t.tolls_amount
  , t.total_amount
  , t.is_negative_fare
  , t.is_zero_distance
FROM
    {{ ref('stg_trips') }} t
LEFT JOIN
    {{ ref('dim_location') }} pl
    ON t.pickup_location_id = pl.location_id
LEFT JOIN
    {{ ref('dim_location') }} dl
    ON t.dropoff_location_id = dl.location_id