#!/bin/bash
set -e

# Fetch the latest vLLM commit from main branch
echo "Fetching latest vLLM commit..."
LATEST_COMMIT=$(git ls-remote https://github.com/vllm-project/vllm.git refs/heads/main | cut -f1)

echo "Latest vLLM commit: $LATEST_COMMIT"

# Update base_commit.txt
echo "$LATEST_COMMIT" > base_commit.txt

# Build the nightly image with caching
docker build -f Dockerfile \
  --build-arg VLLM_BASE_COMMIT="$LATEST_COMMIT" \
  --build-arg VLLM_CHECKOUT_COMMIT="$LATEST_COMMIT" \
  -t llm-d-dev:nightly \
  -t "llm-d-dev:nightly-$LATEST_COMMIT" \
  -t quay.io/tms/llm-d-dev:latest \
  -t "quay.io/tms/llm-d-dev:nightly-$LATEST_COMMIT" \
  .

# Push to registry
echo "Pushing to registry..."
docker push quay.io/tms/llm-d-dev:latest
docker push "quay.io/tms/llm-d-dev:nightly-$LATEST_COMMIT"

echo "Nightly build complete!"
echo "Local tags: llm-d-dev:nightly and llm-d-dev:nightly-$LATEST_COMMIT"
echo "Pushed to: quay.io/tms/llm-d-dev:latest and quay.io/tms/llm-d-dev:nightly-$LATEST_COMMIT"
echo "vLLM base commit updated in base_commit.txt: $LATEST_COMMIT"
