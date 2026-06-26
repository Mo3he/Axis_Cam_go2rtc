# Build an Axis ACAP package that bundles the go2rtc streaming server.
#
# The go2rtc release binary for the target architecture is downloaded at build
# time, so no binaries are committed to this repository.
#
#   docker build --build-arg ARCH=aarch64 -t go2rtc-acap:aarch64 .
#   docker build --build-arg ARCH=armv7hf -t go2rtc-acap:armv7hf .

ARG ARCH=aarch64
ARG VERSION=1.15.1
ARG UBUNTU_VERSION=22.04
ARG REPO=axisecp
ARG SDK=acap-native-sdk

FROM ${REPO}/${SDK}:${VERSION}-${ARCH}-ubuntu${UBUNTU_VERSION}

# Re-declare after FROM so the args are available in the build stage.
ARG ARCH
ARG GO2RTC_VERSION=v1.9.14

COPY ./app /opt/app/
WORKDIR /opt/app

# Download the matching go2rtc binary for the target architecture.
RUN case "${ARCH}" in \
        aarch64) GO2RTC_ARCH=arm64 ;; \
        armv7hf) GO2RTC_ARCH=arm ;; \
        *) echo "Unsupported ARCH: ${ARCH}" && exit 1 ;; \
    esac && \
    curl -fsSL -o lib/go2rtc \
        "https://github.com/AlexxIT/go2rtc/releases/download/${GO2RTC_VERSION}/go2rtc_linux_${GO2RTC_ARCH}" && \
    chmod +x lib/go2rtc

# Stamp the architecture into the manifest.
RUN sed -i "s/@ARCH@/${ARCH}/" manifest.json

# Build the supervisor and package the .eap.
RUN . /opt/axis/acapsdk/environment-setup* && acap-build -a go2rtc_run ./
