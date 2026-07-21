# go2rtc ACAP for Axis Cameras

[![Release](https://img.shields.io/github/v/release/Mo3he/Axis_Cam_go2rtc?style=flat)](https://github.com/Mo3he/Axis_Cam_go2rtc/releases)
[![License](https://img.shields.io/github/license/Mo3he/Axis_Cam_go2rtc?style=flat)](LICENSE)
[![Build](https://github.com/Mo3he/Axis_Cam_go2rtc/actions/workflows/build.yml/badge.svg)](https://github.com/Mo3he/Axis_Cam_go2rtc/actions/workflows/build.yml)
[![Super-Linter](https://github.com/Mo3he/Axis_Cam_go2rtc/actions/workflows/super-linter.yml/badge.svg)](https://github.com/Mo3he/Axis_Cam_go2rtc/actions/workflows/super-linter.yml)
[![Sponsor](https://img.shields.io/badge/Sponsor%20My%20Work-EA4AAA?style=flat&logo=github&logoColor=white)](https://github.com/sponsors/Mo3he)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=flat&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/mo3he)

Run the [go2rtc](https://github.com/AlexxIT/go2rtc) streaming server directly on
an Axis camera as an ACAP application. go2rtc is a single, zero-dependency Go
binary, so it packages cleanly into a native ACAP.

> **Disclaimer:** Independent, community-developed ACAP package. Not an official
> Axis product and not affiliated with, endorsed by, or supported by Axis
> Communications AB or the go2rtc project. Use at your own risk.

## Overview

Watch the camera live in any modern browser over **WebRTC**, with sub-second
latency and no plugin or RTSP client required. go2rtc converts the camera's RTSP
into WebRTC / MSE / HLS / MJPEG on the fly, acting as a protocol bridge for
clients that can't speak RTSP, and restreams a single feed to many viewers from
the camera itself. It is also a great building block for web apps: a
standards-based WebRTC/HTTP endpoint straight from the device.

- The full go2rtc dashboard (WebRTC / MSE / RTSP players, config editor, stream
  stats) served from the camera on port `1984`.
- An RTSP server on `8554` and WebRTC on `8555`.
- Runs as the unprivileged ACAP user (no root required).
- Config is stored on the device and survives restarts; removed on uninstall.

## Compatibility

- **AXIS OS:** 11.x through 13.
- **Architectures:** `aarch64` and `armv7hf`.

## Installation

> **Signed packages:** Release `.eap` files are signed with the Axis ACAP
> signing service and install normally on AXIS OS 12.10 and later.
>
> **Upgrading from an earlier version?** The signing vendor changed, so
> installing over a previously installed unsigned build can fail with
> **"Couldn't install: app"** (device log: *"Vendor ID in manifest does not
> match the vendor ID of the previous version"*). To upgrade: back up your app
> configuration, **uninstall** the old version, then install the signed one.

Download the `.eap` from the [latest release](https://github.com/Mo3he/Axis_Cam_go2rtc/releases)
and install it via the camera's web interface under **Apps -> Add app**, then
start the app. Click **Open** (or browse to `http://<camera-ip>:1984/`) to reach
the dashboard.

## Configuration

Add streams from the dashboard's **Config** tab. For the camera's own stream,
use a local RTSP URL:

```yaml
streams:
  camera: rtsp://USER:PASS@127.0.0.1:554/axis-media/media.amp
```

## Ports & security

| Service | Port | URL |
|---|---|---|
| Web UI / HTTP API | `1984` | `http://<camera-ip>:1984/` |
| RTSP server | `8554` | `rtsp://<camera-ip>:8554/<stream>` |
| WebRTC | `8555` | TCP/UDP |

> **Security:** by default the Web UI / API on `1984` has no authentication.
> go2rtc can run shell commands through its source modules, so an open API is
> effectively remote access to the device. Before exposing the app beyond a
> trusted network, set `username` / `password` under `api:` in
> `app/go2rtc.yaml` (and `rtsp:` if you serve RTSP), and prefer a dedicated
> limited-privilege device account in your stream URLs.

## How it works

| File | Role |
|---|---|
| `app/manifest.json` | ACAP metadata; `architecture` is stamped in at build time. |
| `app/supervisor.c` | Tiny ACAP main executable. Launches the run script, restarts it if it dies, forwards `SIGTERM` for a clean stop. |
| `app/go2rtc_run` | Seeds the default config into `localdata/` on first run, then `exec`s the go2rtc binary. |
| `app/go2rtc.yaml` | Default config, copied to the persistent `localdata/` dir once. |
| `app/lib/go2rtc` | go2rtc binary, downloaded during the Docker build. |
| `app/html/index.html` | Settings page with a link to the dashboard. |

## Build from source

Requires Docker. The go2rtc release binary is downloaded at build time, so no
binaries are committed here.

```sh
./build.sh                      # builds aarch64 and armv7hf
ARCHS="aarch64" ./build.sh      # single architecture
GO2RTC_VERSION=v1.9.14 ./build.sh
```

The resulting `go2rtc_*_<arch>.eap` files are copied into the project root.

## Notes

- **ffmpeg is optional and modular.** No ffmpeg binary ships in this package.
  ffmpeg-dependent features (JPEG snapshots, transcoding, any `ffmpeg:` source)
  are disabled until you install the companion ffmpeg ACAP
  ([Mo3he/Axis_Cam_ffmpeg](https://github.com/Mo3he/Axis_Cam_ffmpeg)). Streaming
  that needs no transcoding works without it: WebRTC, MSE, RTSP, and MP4 pass the
  camera's H.264 through untouched.
- WebRTC works best on the local network. For external access, port `8555`
  (TCP/UDP) must be reachable, or configure a TURN server in go2rtc.
- To serve the dashboard under the camera's own web server suburl instead of
  port `1984`, set `api.base_path` in `go2rtc.yaml` and add a `reverseProxy`
  entry to the manifest.

## Links

- [go2rtc](https://github.com/AlexxIT/go2rtc)
- [Axis Communications](https://www.axis.com/)

## License

The packaging code in this repository is licensed under BSD 3-Clause (see
[LICENSE](LICENSE)). Bundled upstream components are listed in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
