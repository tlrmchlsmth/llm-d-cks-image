build:
  docker build -f Dockerfile.ubi \
    -t quay.io/tms/llm-d-dev:0.2.0-l . \
  && docker push quay.io/tms/llm-d-dev:0.2.0-l
