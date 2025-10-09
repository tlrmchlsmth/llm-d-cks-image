FROM ghcr.io/llm-d/llm-d-cuda-dev:latest

USER root

RUN mkdir -p /home/code && \
    git clone https://github.com/vllm-project/vllm.git /home/code/vllm

WORKDIR /home/code/vllm

# Add all remotes upfront
RUN git remote add vllm https://github.com/vllm-project/vllm && \
  git remote add njhill https://github.com/njhill/vllm && \
  git remote add tms https://github.com/tlrmchlsmth/vllm && \
  git remote add nm https://github.com/neuralmagic/vllm

# Install vLLM at base commit (large layer, cached by nightly builds)
ARG VLLM_BASE_COMMIT
RUN --mount=type=cache,target=/root/.cache/uv \
  source /opt/vllm/bin/activate && \
  git fetch --all && \
  git checkout -q ${VLLM_BASE_COMMIT} && \
  VLLM_USE_PRECOMPILED=1 uv pip install -e .

# Checkout specific commit for testing (small layer, changes frequently)
ARG VLLM_CHECKOUT_COMMIT=${VLLM_BASE_COMMIT}
RUN git checkout -q ${VLLM_CHECKOUT_COMMIT}

ENTRYPOINT ["/opt/vllm/bin/python", "-m", "vllm.entrypoints.openai.api_server"]
