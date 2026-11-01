import argparse
from pathlib import Path

import requests

BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data"

def download_month(year, month, out_dir="data/raw/yellow"):
    file_name = f"yellow_tripdata_{year}-{month:02d}.parquet"
    url = f"{BASE_URL}/{file_name}"

    target_dir = Path(out_dir) / f"year={year}" / f"month={month:02d}"
    target_dir.mkdir(parents=True, exist_ok=True)
    target = target_dir / file_name
    tmp = target.with_suffix(".tmp")

    print(f"downloading {url}")
    with requests.get(url, stream=True, timeout=60) as r:
        r.raise_for_status()
        with open(tmp, "wb") as f:
            for chunk in r.iter_content(chunk_size=1024 * 1024):
                f.write(chunk)

    # only replace the real file once the download is complete
    tmp.replace(target)
    print(f"saved to {target}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--year", type=int, required=True)
    parser.add_argument("--month", type=int, required=True)
    args = parser.parse_args()
    download_month(args.year, args.month)
