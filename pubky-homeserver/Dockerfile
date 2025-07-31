# Use Rust 1.75 as base image
FROM rust:1.75-slim as builder

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone the pubky-homeserver repository
RUN git clone https://github.com/pubky/pubky-homeserver.git .

# Build the application
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN useradd -r -s /bin/false pubky

# Set working directory
WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /app/target/release/pubky-homeserver /app/pubky-homeserver

# Copy entrypoint script
COPY config/homeserver.entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Create data directory
RUN mkdir -p /data && chown pubky:pubky /data

# Switch to app user
USER pubky

# Expose port 8080
EXPOSE 8080

# Use entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]