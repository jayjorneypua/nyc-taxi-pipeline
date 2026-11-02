SELECT
    vendor_id
  , pickup_at
  , dropoff_at
  , passenger_count
  , rate_code_id
  , trip_distance
  , pickup_location_id
  , dropoff_location_id
  , payment_type
  , fare_amount
  , tip_amount
  , tolls_amount
  , total_amount
  , is_negative_fare
  , is_zero_distance
  , file_year
  , file_month
  , _ingested_at
FROM
    {{ source('silver', 'trips') }}