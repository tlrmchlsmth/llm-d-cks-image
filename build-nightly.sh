#!/bin/bash
# Wrapper script for cron job - delegates to Justfile with timestamps
cd "$(dirname "${BASH_SOURCE[0]}")"

# Set PATH to include cargo bin directory for nested just calls
export PATH="/home/tms/.cargo/bin:$PATH"

# Add timestamp to each line of output
just nightly 2>&1 | while IFS= read -r line; do
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line"
done

# Preserve exit status
exit ${PIPESTATUS[0]}
