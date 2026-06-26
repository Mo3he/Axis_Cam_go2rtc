#!/bin/sh
# Build the go2rtc ACAP for one or more architectures and copy the .eap files
# into the current directory.
#
# Usage:
#   ./build.sh                 # builds aarch64 and armv7hf
#   ARCHS="aarch64" ./build.sh # build a single architecture
#   GO2RTC_VERSION=v1.9.14 ./build.sh
set -eu

ARCHS="${ARCHS:-aarch64 armv7hf}"
GO2RTC_VERSION="${GO2RTC_VERSION:-v1.9.14}"

for arch in $ARCHS; do
    echo "==> Building go2rtc ACAP for $arch (go2rtc $GO2RTC_VERSION)"
    docker build \
        --build-arg ARCH="$arch" \
        --build-arg GO2RTC_VERSION="$GO2RTC_VERSION" \
        -t "go2rtc-acap:$arch" .

    cid="$(docker create "go2rtc-acap:$arch")"
    rm -rf "build_$arch"
    docker cp "$cid:/opt/app" "build_$arch"
    docker rm "$cid" >/dev/null
    cp build_"$arch"/*.eap . 2>/dev/null || true
    echo "==> Done: $(ls build_"$arch"/*.eap 2>/dev/null || echo '(no .eap found)')"
done
