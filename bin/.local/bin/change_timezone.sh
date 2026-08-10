#!/bin/bash

DEFAULT_TZ="Europe/Paris"

# Check for required tools
for cmd in fzf awk; do
  if ! command -v "$cmd" >/dev/null; then
    echo "❌ '$cmd' is required. Install it with: sudo apt install $cmd"
    exit 1
  fi
done

# Get all timezones
ALL_TZS=$(timedatectl list-timezones)

# Extract top-level zones and standalone timezones
TOP_LEVEL=$(echo "$ALL_TZS" | awk -F'/' '{print $1}' | sort -u)
STANDALONES=$(echo "$ALL_TZS" | grep -v '/' | sort -u)
ALL_FIRST_LEVEL=$(echo -e "$TOP_LEVEL\n$STANDALONES" | sort -u)

echo "🌍 Select a region or standalone timezone:"
REGION_OR_ZONE=$(echo "$ALL_FIRST_LEVEL" | fzf --prompt="Timezone/Region: ")

if [ -z "$REGION_OR_ZONE" ]; then
  echo "↩️ No selection made. Reverting to default timezone: $DEFAULT_TZ"
  SELECTED_TZ="$DEFAULT_TZ"
else
  # Check how many matching timezones exist
  MATCHING_TZS=$(echo "$ALL_TZS" | grep "^$REGION_OR_ZONE")

  COUNT=$(echo "$MATCHING_TZS" | wc -l)

  if [ "$COUNT" -eq 1 ]; then
    # Only one timezone matches (e.g. 'Japan' or 'UTC')
    SELECTED_TZ="$REGION_OR_ZONE"
  else
    # Multiple timezones — ask user to select one
    CITY_LIST=$(echo "$MATCHING_TZS" | while read TZ_NAME; do
      OFFSET=$(TZ=$TZ_NAME date +%z)
      if [[ $OFFSET =~ ^([+-])([0-9]{2})([0-9]{2})$ ]]; then
        SIGN=${BASH_REMATCH[1]}
        HOUR=${BASH_REMATCH[2]}
        MIN=${BASH_REMATCH[3]}
        FORMATTED="${SIGN}${HOUR}:${MIN}"
        echo "(GMT${FORMATTED}) $TZ_NAME"
      else
        echo "(GMT??:??) $TZ_NAME"
      fi
    done)

    echo "🏙️ Select a timezone in $REGION_OR_ZONE:"
    SELECTED=$(echo "$CITY_LIST" | fzf --prompt="City in $REGION_OR_ZONE: ")

    if [ -z "$SELECTED" ]; then
      echo "↩️ No timezone selected. Reverting to $DEFAULT_TZ"
      SELECTED_TZ="$DEFAULT_TZ"
    else
      SELECTED_TZ=$(echo "$SELECTED" | awk '{print $2}')
    fi
  fi
fi

# Apply the selected timezone
echo "✅ Applying timezone: $SELECTED_TZ"
sudo timedatectl set-timezone "$SELECTED_TZ"

# Display result
timedatectl | grep 'Time zone'
