# Data Profiling — Yellow Taxi, January 2024

Source file: `yellow_tripdata_2024-01.parquet` (2,964,624 trips)

| Check | Count | Planned handling |
|---|---|---|
| Pickup outside the file's month (earliest: 2002-12-31) | — | Drop: invalid timestamp |
| Dropoff before pickup | 56 | Drop: physically impossible |
| Negative fares | 37,448 | Keep, flag: likely refunds or voids |
| Zero or null passengers | 171,627 | Keep, treat as unknown |
| Zero trip distance | 60,371 | Keep, flag: possible cancellations or meter glitches |