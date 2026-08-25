#!/bin/sh
# Build the go2rtc ACAP for one or more architectures and copy the .eap files
# into the repository root. Also builds the go2rtc HKSV variant (app_hksv/,
# Dockerfile.hksv), which installs as a separate app (go2rtc_hksv) using
# binaries from Mo3he/go2rtc's rolling "hksv-latest" release.
#
# Usage:
#   ./build.sh                 # builds aarch64 and armv7hf
#   ./build.sh aarch64         # build a single architecture
#   GO2RTC_VERSION=v1.9.14 ./build.sh
#
# Override the container runtime with RUNTIME=docker|podman.
set -eu

# Auto-detect container runtime: prefer docker when its daemon is reachable,
# otherwise fall back to podman.
if [ -z "${RUNTIME:-}" ]; then
	if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
		RUNTIME=docker
	elif command -v podman >/dev/null 2>&1; then
		RUNTIME=podman
	elif command -v docker >/dev/null 2>&1; then
		RUNTIME=docker
	else
		echo 'Error: neither docker nor podman found in PATH' >&2
		exit 1
	fi
fi
echo "==> Using container runtime: ${RUNTIME}"

GO2RTC_VERSION="${GO2RTC_VERSION:-v1.9.14}"

# Architectures: positional args win, else ARCHS env, else both.
if [ "$#" -gt 0 ]; then
	ARCHS="$*"
else
	ARCHS="${ARCHS:-aarch64 armv7hf}"
fi

for arch in $ARCHS; do
	echo "==> Building go2rtc ACAP for $arch (go2rtc $GO2RTC_VERSION)"
	"$RUNTIME" build \
		--build-arg ARCH="$arch" \
		--build-arg GO2RTC_VERSION="$GO2RTC_VERSION" \
		-t "go2rtc-acap:$arch" .

	cid="$("$RUNTIME" create "go2rtc-acap:$arch")"
	rm -rf "build_$arch"
	"$RUNTIME" cp "$cid:/opt/app" "build_$arch"
	"$RUNTIME" rm "$cid" >/dev/null
	cp build_"$arch"/*.eap . 2>/dev/null || true
	echo "==> Done: $(ls build_"$arch"/*.eap 2>/dev/null || echo '(no .eap found)')"

	echo "==> Building go2rtc HKSV ACAP for $arch"
	"$RUNTIME" build \
		--build-arg ARCH="$arch" \
		-f Dockerfile.hksv \
		-t "go2rtc-hksv-acap:$arch" .

	cid="$("$RUNTIME" create "go2rtc-hksv-acap:$arch")"
	rm -rf "build_hksv_$arch"
	"$RUNTIME" cp "$cid:/opt/app" "build_hksv_$arch"
	"$RUNTIME" rm "$cid" >/dev/null
	cp build_hksv_"$arch"/*.eap . 2>/dev/null || true
	echo "==> Done: $(ls build_hksv_"$arch"/*.eap 2>/dev/null || echo '(no .eap found)')"
done
