FROM ghcr.io/llm-d/llm-d-cuda-dev:pr-254

RUN git clone https://github.com/vllm-project/vllm.git /home/code/vllm

WORKDIR /home/code/vllm

ARG VLLM_BASE_COMMIT
RUN --mount=type=cache,target=/root/.cache/uv \
  source /opt/vllm/bin/activate && \
  git remote add vllm https://github.com/vllm-project/vllm && \
  git fetch vllm && \
  git checkout -q ${VLLM_BASE_COMMIT} && \
  VLLM_USE_PRECOMPILED=1 uv pip install -e .

ARG VLLM_CHECKOUT_COMMIT=${VLLM_BASE_COMMIT}
RUN --mount=type=cache,target=/root/.cache/uv \
  git remote add njhill https://github.com/njhill/vllm && \
  git remote add tms https://github.com/tlrmchlsmth/vllm && \
  git remote add nm https://github.com/neuralmagic/vllm && \
  git fetch tms && \
  git fetch njhill && \
  git fetch vllm && \
  git fetch nm && \
  git checkout -q ${VLLM_CHECKOUT_COMMIT}

ENTRYPOINT ["/opt/vllm/bin/python", "-m", "vllm.entrypoints.openai.api_server"]
