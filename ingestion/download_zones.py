from pathlib import Path

import requests

ZONES_URL = "https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv"

def download_zones(out_dir="data/raw/zones"):
    target_dir = Path(out_dir)
    target_dir.mkdir(parents=True, exist_ok=True)
    target = target_dir / "taxi_zone_lookup.csv"
    tmp = target.with_suffix(".tmp")

    print(f"downloading {ZONES_URL}")
    r = requests.get(ZONES_URL, timeout=60)
    r.raise_for_status()
    tmp.write_bytes(r.content)

    tmp.replace(target)
    print(f"saved to {target}")


if __name__ == "__main__":
    download_zones()