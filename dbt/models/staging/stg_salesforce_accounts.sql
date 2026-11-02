SELECT
    Id                    AS account_id
  , Name                  AS account_name
  , Industry              AS industry
  , Pricing_Tier__c       AS pricing_tier
  , Account_Manager__c    AS account_manager
  , IsDeleted             AS is_deleted
  , COALESCE(
        try_to_timestamp(CAST(SystemModstamp AS STRING), "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
      , CAST(SystemModstamp AS TIMESTAMP)
    )                     AS modified_at
FROM
    {{ source('bronze', 'salesforce_accounts') }}
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY
        Id
    ORDER BY
        SystemModstamp DESC
      , _ingested_at   DESC
) = 1