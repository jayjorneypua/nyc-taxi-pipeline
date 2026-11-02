WITH snap AS (
    SELECT
        *
      , ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY dbt_valid_from) AS version_number
    FROM
        {{ ref('snap_salesforce_accounts') }}
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['account_id', 'dbt_valid_from']) }} AS client_key
  , account_id
  , DENSE_RANK() OVER (ORDER BY account_id) - 1    AS client_number
  , account_name
  , industry
  , pricing_tier
  , account_manager
  , is_deleted
  , version_number
  , CASE
        WHEN version_number = 1 THEN TIMESTAMP'1900-01-01'
        ELSE dbt_valid_from
    END                                            AS valid_from
  , COALESCE(dbt_valid_to, TIMESTAMP'9999-12-31')  AS valid_to
  , dbt_valid_to IS NULL                           AS is_current
FROM
    snap