SELECT
    LocationID  AS location_id
  , Borough     AS borough
  , Zone        AS zone_name
  , service_zone
FROM
    {{ source('bronze', 'zones')}}