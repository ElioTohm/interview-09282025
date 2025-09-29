ARG BITCOIN_VERSION=29.0

# Use a minimal base image
FROM alpine:3.20 AS builder

# Bitcoin Core version to install.
ARG BITCOIN_VERSION
ARG BITCOIN_URL=https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}
ARG BITCOIN_SHA256SUMS_URL=${BITCOIN_URL}/SHA256SUMS
ARG BITCOIN_SHA256SUMS_ASC_URL=${BITCOIN_URL}/SHA256SUMS.asc

# Build-time dependencies
RUN apk add --no-cache \
    curl \
    gnupg \
    gpg-agent \
    python3 \
    git \
    tar

WORKDIR /

ENV SIGS_REPO_URL="https://github.com/bitcoin-core/guix.sigs.git"
ENV SIGS_CLONE_DIR="guix.sigs"
ENV TMPDIR="/tmp/bitcoin_verify_binaries"
ENV TARGETPLATFORM=aarch64-linux-gnu

COPY verify.py .
RUN set -ex \
    && git clone ${SIGS_REPO_URL} ${SIGS_CLONE_DIR} \
    && gpg --import "${SIGS_CLONE_DIR}"/builder-keys/* \
    && ./verify.py \
    --min-good-sigs 6 pub "${BITCOIN_VERSION}-linux" \
    && tar -xzf "${TMPDIR}.${BITCOIN_VERSION}-linux/bitcoin-${BITCOIN_VERSION}-${TARGETPLATFORM}.tar.gz" -C /opt \
    && rm -rf ${SIGS_CLONE_DIR} \
    && rm -rf ${TMPDIR} \
    && rm -rf /opt/bitcoin-${BITCOIN_VERSION}/bin/bitcoin-qt

RUN ls /opt/bitcoin-${BITCOIN_VERSION}/bin

FROM debian:bookworm-slim

ARG BITCOIN_VERSION
ENV BITCOIN_DATA=/var/lib/bitcoin

RUN echo ${BITCOIN_VERSION}

ARG UID=1000
ARG GID=1000

ENV PATH=/opt/bin:$PATH

RUN groupadd --gid ${GID} bitcoin \
    && useradd --create-home --no-log-init -u ${UID} -g ${GID} bitcoin \
    && apt-get update -y \
    && apt-get install -y gosu --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy Bitcoin Core binaries from builder
COPY --from=builder /opt/bitcoin-${BITCOIN_VERSION}/bin/bitcoind /opt/bin/bitcoind
COPY --from=builder /opt/bitcoin-${BITCOIN_VERSION}/bin/bitcoin-cli /opt/bin/bitcoin-cli

# Copy configuration and entrypoint script
COPY entrypoint.sh /

# Expose ports
EXPOSE 8332 8333 18332 18333 18443 18444 38333 38332

ENV PATH=/opt/bin:$PATH

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD bitcoin-cli -rpcwait getblockchaininfo > /dev/null || exit 1

VOLUME ["/var/lib/bitcoin"]

EXPOSE 8332 8333 18332 18333 18444

RUN bitcoind --version | grep "Bitcoin Core daemon version v"

CMD ["bitcoind"]


