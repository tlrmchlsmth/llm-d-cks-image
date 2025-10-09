BASE_COMMIT := `cat base_commit.txt`

# Build and push image with custom checkout commit (uses cached base commit layer)
build HASH:
  docker build -f Dockerfile \
    --build-arg VLLM_BASE_COMMIT={{BASE_COMMIT}} \
    --build-arg VLLM_CHECKOUT_COMMIT={{HASH}} \
    --cache-from llm-d-dev:nightly \
    -t quay.io/tms/llm-d-dev:0.3.0-{{HASH}} . \
  && docker push quay.io/tms/llm-d-dev:0.3.0-{{HASH}}

# Build nightly image with latest vLLM commit and push to registry
nightly:
  ./build-nightly.sh
