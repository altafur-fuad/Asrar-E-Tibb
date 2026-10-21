# ==============================================================================
# Multi-stage Dockerfile for Asrar-e-Tibb Rust Backend API
# Target: Render / Production Linux Container
# ==============================================================================

# --- Stage 1: Build Stage ---
FROM rust:1.80-slim-bullseye AS builder

WORKDIR /usr/src/app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency specifications first for layer caching
COPY Cargo.toml ./

# Create dummy source to cache dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -rf src

# Copy real source code
COPY src ./src

# Force rebuild of real application binary
RUN touch src/main.rs && cargo build --release

# --- Stage 2: Lean Runtime Stage ---
FROM debian:bullseye-slim AS runtime

WORKDIR /app

# Install minimal SSL runtime certificates
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create unprivileged runtime user
RUN useradd -m -u 10001 -s /bin/sh appuser

# Copy compiled binary from builder
COPY --from=builder /usr/src/app/target/release/asrar-e-tibb-api /usr/local/bin/asrar-e-tibb-api

# Set ownership
RUN chown -R appuser:appuser /app

USER appuser

# Default port expected by Render
ENV PORT=10000
ENV HOST=0.0.0.0

EXPOSE 10000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:10000/healthz || exit 1

ENTRYPOINT ["/usr/local/bin/asrar-e-tibb-api"]
