#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create cron job that runs nightly build at 2 AM
CRON_JOB="0 2 * * * cd $REPO_DIR && $REPO_DIR/build-nightly.sh >> $REPO_DIR/nightly-build.log 2>&1"

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "build-nightly.sh"; then
    echo "Cron job already exists. To update it, first remove the existing job with:"
    echo "  crontab -e"
    echo "Then run this script again."
    exit 1
fi

# Add cron job
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "Cron job added successfully!"
echo "The nightly build will run daily at 2:00 AM"
echo "Logs will be written to: $REPO_DIR/nightly-build.log"
echo ""
echo "To view the cron job: crontab -l"
echo "To remove the cron job: crontab -e"
