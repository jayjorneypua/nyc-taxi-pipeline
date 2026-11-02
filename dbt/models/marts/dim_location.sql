SELECT
    {{ dbt_utils.generate_surrogate_key(['location_id']) }} AS location_key
  , location_id
  , borough
  , zone_name
  , service_zone
FROM
    {{ ref('stg_zones') }}