# Data profiling - yellow taxi jan 2024

File: yellow_tripdata_2024-01.parquet
Rows: 2,964,624

What I found:
- earliest pickup is 2002-12-31, latest is 2024-02-01. some timestamps are way off
- 56 trips where dropoff is before pickup
- 37,448 negative fares
- 171,627 trips with 0 or null passengers
- 60,371 trips with 0 distance

Plan for silver:
- drop bad timestamps and dropoff before pickup
- keep negative fares but flag them, probably refunds
- keep 0/null passengers, treat as unknown
- keep 0 distance but flag it