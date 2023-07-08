#! /usr/bin/env bash

image=""
key_file=""

# Function to display script usage
function display_usage {
  echo "Usage: $0 --image <image> [--key-file <key_file>]"
  echo "  --image <image>    : GCR-hosted docker image to check"
  echo "  --key-file <key_file> (optional) : Path to the GCP key file"
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --image)
      shift
      image=$1
      ;;
    --key-file)
      shift
      key_file=$1
      ;;
    *)
      echo "Invalid argument: $1"
      display_usage
      exit 1
      ;;
  esac
  shift
done

# Validate required arguments
if [[ -z "$image" ]]; then
  echo "Missing required argument: --image"
  display_usage
  exit 1
fi

if [[ -n "$key_file" ]]; then
  # Authenticate with GCP if --key-file is provided
  echo "Authenticating with GCP using key file: $key_file"
  gcloud auth activate-service-account --key-file="$key_file"
fi

# Check for the image
echo "Checking for image $image"
output=$(gcloud container images describe "$image" 2>&1)

# Print the output
echo "$output"

# Check the output for an error message
if echo "$output" | grep -q "ERROR:"; then
  echo "It is possible the image does not exist"
  echo "Doublecheck the image name and tag, then confirm that the image was actually built and successfully pushed to GCR."
  exit 1
fi
