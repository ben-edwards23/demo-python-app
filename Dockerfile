# Builder Stage
FROM python:3.12-slim AS builder
WORKDIR /build

# We don't want to cache dependencies, they bloat the Docker image.
ENV PIP_NO_CACHE_DIR=1

# Copy the requirements file
COPY app/requirements.txt .

# Run pip install
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip wheel --wheel-dir=/build/wheels -r requirements.txt

# Runtime Stage
FROM python:3.12-slim

# Add the Virtual Environment to PATH so we can use the packages installed in the builder stage.
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV PORT=8000
WORKDIR /app

# Copy the wheels from Builder Stage
COPY --from=builder /build/wheels /wheels
RUN python -m venv $VIRTUAL_ENV && \
    pip install --no-cache-dir /wheels/*

# Copy the application code
COPY app/ /app/

# Gunicorn entrypoint
CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]