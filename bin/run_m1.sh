#!/usr/bin/env bash
# run_m1.sh — Runs the Raven M1 (Remove Duplicates) maintenance operation.
# Intended to be called by cron or manually.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/m1_$(date +%Y%m%d_%H%M%S).log"

echo "[$(date)] Starting M1 Operation..." >> "$LOG_FILE"
java -jar "$SCRIPT_DIR/raven-jobs-1.0-SNAPSHOT.jar" >> "$LOG_FILE" 2>&1
EXIT_CODE=$?
echo "[$(date)] M1 Operation complete (exit code: $EXIT_CODE)." >> "$LOG_FILE"
exit $EXIT_CODE
