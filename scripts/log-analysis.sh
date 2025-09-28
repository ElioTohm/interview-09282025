#!/bin/bash
set -o pipefail

FILE_PATH="${1:--}"

if [[ "$FILE_PATH" != "-" && ! -r "$FILE_PATH" ]]; then
  echo "Error: File not found or not readable: $FILE_PATH" >&2
  exit 1
fi

cat "$FILE_PATH" |
  awk '$2 ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}$/ {print $2}' |
  sort |
  uniq -c |
  sort -rn |
  awk '{print $1, $2}'
