BASE_COMMIT := "6a3d470b5e320c59ebcb36123c86234c754a03e1"

build HASH:
  docker build -f Dockerfile.ubi \
    --build-arg VLLM_BASE_COMMIT={{BASE_COMMIT}} \
    --build-arg VLLM_CHECKOUT_COMMIT={{HASH}} \
    -t quay.io/tms/llm-d-dev:0.2.0-{{HASH}} . \
  && docker push quay.io/tms/llm-d-dev:0.2.0-{{HASH}}
