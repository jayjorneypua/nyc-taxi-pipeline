import json
import os
from datetime import datetime, timezone
from pathlib import Path

import requests
from dotenv import load_dotenv

API_VERSION = "v62.0"
FIELDS = [
    "Id",
    "Name",
    "Industry",
    "Pricing_Tier__c",
    "Account_Manager__c",
    "IsDeleted",
    "CreatedDate",
    "SystemModstamp",
]


def get_token(domain, client_id, client_secret):
    r = requests.post(
        f"https://{domain}/services/oauth2/token",
        data={
            "grant_type": "client_credentials",
            "client_id": client_id,
            "client_secret": client_secret,
        },
        timeout=30,
    )
    r.raise_for_status()
    body = r.json()
    return body["access_token"], body["instance_url"]


def query_all(instance_url, token, soql):
    # queryAll also returns deleted records, so deletes can be tracked downstream
    url = f"{instance_url}/services/data/{API_VERSION}/queryAll"
    params = {"q": soql}
    headers = {"Authorization": f"Bearer {token}"}
    records = []

    while url:
        r = requests.get(url, headers=headers, params=params, timeout=60)
        r.raise_for_status()
        body = r.json()
        records.extend(body["records"])

        # salesforce returns results in pages, nextRecordsUrl points to the next one
        next_url = body.get("nextRecordsUrl")
        url = f"{instance_url}{next_url}" if next_url else None
        params = None

    return records


def to_soql_datetime(sf_timestamp):
    # salesforce returns 2026-11-02T10:15:30.000+0000, soql wants 2026-11-02T10:15:30Z
    dt = datetime.strptime(sf_timestamp, "%Y-%m-%dT%H:%M:%S.%f%z")
    return dt.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def download_accounts(out_dir="data/raw/salesforce/accounts"):
    load_dotenv()
    domain = os.environ["SF_DOMAIN"]
    client_id = os.environ["SF_CLIENT_ID"]
    client_secret = os.environ["SF_CLIENT_SECRET"]

    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    state_file = out.parent / "_state" / "accounts_watermark.txt"
    watermark = state_file.read_text().strip() if state_file.exists() else None

    soql = f"SELECT {', '.join(FIELDS)} FROM Account"
    if watermark:
        # >= instead of > so changes made in the same second aren't missed
        soql += f" WHERE SystemModstamp >= {watermark}"
    soql += " ORDER BY SystemModstamp"

    token, instance_url = get_token(domain, client_id, client_secret)
    records = query_all(instance_url, token, soql)

    if not records:
        print("no changed accounts")
        return 0

    for rec in records:
        rec.pop("attributes", None)

    extracted_at = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    target = out / f"accounts_{extracted_at}.json"
    tmp = target.with_suffix(".tmp")
    with open(tmp, "w") as f:
        for rec in records:
            f.write(json.dumps(rec) + "\n")
    tmp.replace(target)

    # only move the watermark after the file is safely written
    state_file.parent.mkdir(parents=True, exist_ok=True)
    state_file.write_text(to_soql_datetime(records[-1]["SystemModstamp"]))

    print(f"saved {len(records)} accounts to {target}")
    return len(records)


if __name__ == "__main__":
    download_accounts()