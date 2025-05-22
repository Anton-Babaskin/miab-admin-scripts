#!/bin/bash

# === CONFIGURATION ===

LOG_FILE="/var/log/mail.log"
SEEN_FILE="/var/lib/postgrey-seen.log"
PASSED_FILE="/var/lib/postgrey-passed.log"
TMP_NEW="/tmp/postgrey-new.$$"

BOT_TOKEN="your_telegram_bot_token"     # ← YOUR TELEGRAM TOKEN
CHAT_ID="your_telegram_chat_id"         # ← YOUR TELEGRAM CHAT ID

# === FUNCTIONS ===

send_telegram() {
    [[ -z "$BOT_TOKEN" || -z "$CHAT_ID" ]] && return
    curl -s -X POST https://api.telegram.org/bot${BOT_TOKEN}/sendMessage \
         -d chat_id="$CHAT_ID" \
         -d text="$1"
}

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Ensure log files exist
touch "$SEEN_FILE" "$PASSED_FILE"

# === 1. Find NEW greylisted events ===

grep "postgrey" "$LOG_FILE" | grep "greylisted" > "$TMP_NEW"

grep -Fvx -f "$SEEN_FILE" "$TMP_NEW" > "$TMP_NEW.filtered"

if [[ -s "$TMP_NEW.filtered" ]]; then
    while read -r line; do
        echo "$line" >> "$SEEN_FILE"
        MSG="⚠️ New greylisted sender:\n$line"
        send_telegram "$MSG"
    done < "$TMP_NEW.filtered"
fi

# === 2. Find PASSED messages for greylisted IPs ===

# Extract IPs from greylisted lines
GREY_IPS=$(cut -d'[' -f2 "$SEEN_FILE" | cut -d']' -f1 | sort -u)

# Scan for those IPs in successful deliveries
for ip in $GREY_IPS; do
    if grep "status=sent" "$LOG_FILE" | grep -q "$ip"; then
        if ! grep -q "$ip" "$PASSED_FILE"; then
            echo "$ip" >> "$PASSED_FILE"
            MSG="✅ Greylisted sender passed:\n$ip\nMessage successfully delivered."
            send_telegram "$MSG"
        fi
    fi
done

# Clean up
rm -f "$TMP_NEW" "$TMP_NEW.filtered"

exit 0
