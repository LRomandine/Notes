#!/usr/bin/env python3
# Forked from https://github.com/panteLx/Mealie-Enhanced-API


import json
import os
import requests
import sys


def user_input(prompt, valid_options=None, is_url=False, is_text=False):
    # Get user input and remove leading/trailing whitespaces
    user_input = input(prompt).strip()
    if is_url and user_input == "":
        user_input = "http://localhost:9925"
        return user_input

    # Check if input is a URL and starts with "http://" or "https://://"
    if is_url and not user_input.startswith(("http://", "https://")):
        print(f"Invalid URL: {user_input} (URL should start with 'http://' or 'https://')")
        sys.exit()

    # Check if the input is a token and is not empty
    if is_text and not user_input:
        print(f"Field must not be empty")
        sys.exit()

    # Check if the input is within the valid options (if provided)
    if valid_options and user_input not in valid_options:
        print(f"Invalid input. Must be one of {valid_options}")
        sys.exit()

    # Return the validated user input
    return user_input


def get_user_self(api_url, token):
    # Check connection and authentication data
    print(f"nChecking connection and validating auth data...")
    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {token}"}
    # Send a GET request to get data
    response = requests.get(f"{api_url}/api/users/self", headers=headers)
    # Print information about the response
    if response.status_code != 200:
        print(f"Error while connecting to your API! - Status Code: {response.status_code}, Response: {response.text}")
        sys.exit()


def delete_recipes(api_url, headers, slug):
    # Send a DELETE request to delete the specified recipe
    response = requests.delete(f"{api_url}/api/recipes/{slug}", headers=headers)
    # Print information about the deletion response
    print(f"Deleted {slug} - Status Code: {response.status_code}")


# Prompt the user to enter API-Token
token = user_input("Enter your API-Token: ", is_text=True).strip()
api_url = user_input(
    "Enter your API-URL (without path - e.g. http://localhost:9925) or leave blank to use the example: ",
    is_url=True,
    ).strip()

# Check connection and auth data
get_user_self(api_url, token)

directory_path = "."

for filename in os.listdir(directory_path):
    file_path = os.path.join(directory_path, filename)
    if os.path.isfile(file_path):  # Process only files, excluding subdirectories
        # Perform operations on each file
        if filename.endswith(".png"):
            print(f"Processing file: {filename}")
            # Prepare data and headers for the POST request
            data = {'images': open(file_path, 'rb')}
            headers = {"Authorization": f"Bearer {token}"}

            # Send a POST request to create a new recipe
            response = requests.post(
                f"{api_url}/api/recipes/create/image", files=data, headers=headers
            )

            # Print information about the response
            if response.status_code == 201:
                print(f"Created recipe - image: {file_path}")
            else:
                print(f"Parse Error - image: {file_path}, Status Code: {response.status_code}, Response: {response.text}")

            # Extract the recipe slug from the response
            slug = response.text.strip('"')

            # Check if the slug is a digit (indicating a duplicate)
            if slug[-1].isdigit():
                # Prompt the user to delete the duplicate recipe
                user_input_delete = (
                    input(f"Duplicate found! Do you want to delete it? (yes, no or blank): ")
                    .strip()
                    .lower()
                )
                if user_input_delete == "yes":
                    # Call the delete_recipes function to delete the duplicate recipe
                    delete_recipes(api_url, headers, slug)
