{{ config(
    materialized            = 'incremental'
  , incremental_strategy    = 'merge'
  , unique_key              = 'trip_key'
) }}

WITH trips AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'trip.vendor_id'
          , 'trip.pickup_at'
          , 'trip.dropoff_at'
          , 'trip.pickup_location_id'
          , 'trip.dropoff_location_id'
          , 'trip.total_amount'
        ]) }} AS trip_key
      , trip.*
    FROM
        {{ ref('stg_trips') }} trip
    {% if is_incremental() %}
    WHERE
        trip.ingested_at > (SELECT MAX(_ingested_at) FROM {{ this }})
    {% endif %}
)
, client_count AS (
    SELECT
        COUNT(DISTINCT client_number) AS n
    FROM
        {{ ref('dim_client') }}
)
, assigned AS (
    SELECT
        trips.*
      , CASE
            WHEN pmod(xxhash64(trips.trip_key), 100) < 30
            THEN pmod(xxhash64(trips.trip_key, 'client'), client_count.n)
        END AS client_number
    FROM
        trips
    CROSS JOIN
        client_count
)
SELECT
    a.trip_key
  , CAST(date_format(a.pickup_at, 'yyyyMMdd') AS INT) AS pickup_date_key
  , pl.location_key                                   AS pickup_location_key
  , dl.location_key                                   AS dropoff_location_key
  , c.client_key
  , a.vendor_id
  , a.payment_type
  , a.rate_code_id
  , a.pickup_at
  , a.dropoff_at
  , (unix_timestamp(a.dropoff_at) - unix_timestamp(a.pickup_at)) / 60.0 AS trip_minutes
  , a.passenger_count
  , a.trip_distance
  , a.fare_amount
  , a.tip_amount
  , a.tolls_amount
  , a.total_amount
  , a.is_negative_fare
  , a.is_zero_distance
  , a._ingested_at
FROM
    assigned a
LEFT JOIN
    {{ ref('dim_location') }} pl
    ON a.pickup_location_id = pl.location_id
LEFT JOIN
    {{ ref('dim_location') }} dl
    ON a.dropoff_location_id = dl.location_id
LEFT JOIN
    {{ ref('dim_client') }} c
    ON a.client_number = c.client_number
    AND a.pickup_at >= c.valid_from
    AND a.pickup_at < c.valid_to