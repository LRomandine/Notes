#!/usr/bin/env python3
# Based on https://github.com/LRomandine/Notes/tree/master/scripts/mealie_bulk_image_import

import json
import os
import requests
import sys
import time
from datetime import datetime, timezone

# Update these for your instance
MEALIE_TOKEN = ""  # Your API key
MEALIE_URL = "http://localhost:9925"  # Your URL (no trialing slash)
MEALIE_BACKUPS_TO_KEEP=4  # The number of backups to keep

def get_user_self(api_url, token):
    print(f"Checking connection and validating auth data...")
    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {token}"}
    response = requests.get(f"{api_url}/api/users/self", headers=headers)
    if response.status_code != 200:
        print(f"Error while connecting to your API! - Status Code: {response.status_code}, Response: {response.text}")
        sys.exit(0)


def check_api_until_success_or_timeout(token, headers, timeout_sec=600, retry_delay_sec=30):
    start_time = time.time()
    while time.time() - start_time < timeout_sec:
        try:
            print("Listing backups...")
            response = requests.get(
                f"{api_url}/api/admin/backups", headers=headers
            )
            if response.status_code != 200:
                print(f"Listing backups FAILED - Status Code: {response.status_code}, Response: {response.text}")
                response.raise_for_status()
            response_json = json.loads(response.text)
            #print(json.dumps(response_json, indent=2))
            if response_json['imports']:
                if len(response_json['imports']) > MEALIE_BACKUPS_TO_KEEP:
                    for index in range(MEALIE_BACKUPS_TO_KEEP, (len(response_json['imports']))):
                        delete_backup(token, headers, response_json['imports'][index]['name'])
                if response_json['imports'][0]:
                    if str(response_json['imports'][0]['date'])[:10] == datetime.now().astimezone(timezone.utc).strftime('%Y-%m-%d'):
                        return response  # Backup created successfully
            print("No backup from today found, sleeping 30 seconds...")
            time.sleep(retry_delay_sec)
        except requests.exceptions.RequestException as e:
            print(f"Listing backups FAILED - Status Code: {response.status_code}, Response: {response.text}")
            time.sleep(retry_delay_sec)
    print("No backup from today found after 10 minutes, aborting.")
    sys.exit(1)


def create_backup(token, headers):
    # Send the API backup command
    response = requests.post(
        f"{api_url}/api/admin/backups", headers=headers
    )
    if response.status_code != 201:
        print(f"Backup creation FAILED - Status Code: {response.status_code}, Response: {response.text}")
        sys.exit(1)


def delete_backup(token, headers, file_name):
    print(f"Backup to delete - {file_name}")
    response = requests.delete(
        f"{api_url}/api/admin/backups/{file_name}", headers=headers
    )
    if response.status_code != 200:
        print(f"Backup deletion FAILED - Status Code: {response.status_code}, Response: {response.text}")
        sys.exit(1)


# Prompt the user to enter API-Token
token = MEALIE_TOKEN
api_url = MEALIE_URL
headers = {"Authorization": f"Bearer {token}"}

# Check connection and auth data
get_user_self(api_url, token)

if create_backup(token, headers):
    print("Backup creation is running...")

if check_api_until_success_or_timeout(token, headers):
    print("Backup was successful.")

sys.exit(0)
