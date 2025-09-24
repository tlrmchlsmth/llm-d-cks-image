BASE_COMMIT := `cat base_commit.txt`

build HASH:
  docker build -f Dockerfile.ubi \
    --build-arg VLLM_BASE_COMMIT={{BASE_COMMIT}} \
    --build-arg VLLM_CHECKOUT_COMMIT={{HASH}} \
    -t quay.io/tms/llm-d-dev:0.3.0-{{HASH}} . \
  && docker push quay.io/tms/llm-d-dev:0.3.0-{{HASH}}
