import argparse
from pathlib import Path

import requests

BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data"


def month_path(out_dir, year, month):
    file_name = f"yellow_tripdata_{year}-{month:02d}.parquet"
    return Path(out_dir) / f"year={year}" / f"month={month:02d}" / file_name


def download_month(year, month, out_dir="data/raw/yellow"):
    target = month_path(out_dir, year, month)
    target.parent.mkdir(parents=True, exist_ok=True)
    tmp = target.with_suffix(".tmp")
    url = f"{BASE_URL}/{target.name}"

    print(f"downloading {url}")
    with requests.get(url, stream=True, timeout=60) as r:
        r.raise_for_status()
        with open(tmp, "wb") as f:
            for chunk in r.iter_content(chunk_size=1024 * 1024):
                f.write(chunk)

    # only replace the real file once the download is complete
    tmp.replace(target)
    print(f"saved to {target}")


def next_month(year, month):
    if month == 12:
        return year + 1, 1
    return year, month + 1


def download_next_month(out_dir="data/raw/yellow", start_year=2024, start_month=1):
    year, month = start_year, start_month

    # skip months we already have
    while month_path(out_dir, year, month).exists():
        year, month = next_month(year, month)

    try:
        download_month(year, month, out_dir)
    except requests.HTTPError:
        # tlc returns an error for months that aren't published yet
        print(f"{year}-{month:02d} not published yet, nothing to do")
        return None

    return year, month


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--year", type=int, required=True)
    parser.add_argument("--month", type=int, required=True)
    args = parser.parse_args()
    download_month(args.year, args.month)