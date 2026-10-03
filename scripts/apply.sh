#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${HOME}/.config/caelestia/shell.json"
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
WEATHER_LOCATION="${WEATHER_LOCATION:-}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: $CONFIG_FILE was not found. Install Caelestia first."
  exit 1
fi

if [[ -z "$WEATHER_LOCATION" ]]; then
  echo "Usage: WEATHER_LOCATION=\"YOUR_CITY,COUNTRY\" $0"
  echo "Example: WEATHER_LOCATION=\"19.0948,74.7480\" $0"
  exit 1
fi

BACKUP="${CONFIG_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
cp -- "$CONFIG_FILE" "$BACKUP"

python - "$CONFIG_FILE" "$ROOT_DIR/config/background.json" "$WEATHER_LOCATION" <<'PY'
import json
import sys
from pathlib import Path

config_path = Path(sys.argv[1])
background_path = Path(sys.argv[2])
weather_location = sys.argv[3]

data = json.loads(config_path.read_text())
background = json.loads(background_path.read_text())

data["background"] = background

data.setdefault("services", {})["weatherLocation"] = weather_location

data["services"].pop("useFahrenheit", None)

config_path.write_text(json.dumps(data, indent=2) + "\n")
print(f"Updated {config_path}")
PY

echo "Backup created: $BACKUP"
echo "Restart Caelestia with: caelestia shell -k && caelestia shell -d"
