# go2rtc ACAP for Axis cameras

Run the [go2rtc](https://github.com/AlexxIT/go2rtc) streaming server directly on
an Axis camera as an ACAP application. go2rtc is a single, zero-dependency Go
binary, so it packages cleanly into a native ACAP.

> Independent, community project. Not affiliated with or endorsed by Axis
> Communications or the go2rtc author. go2rtc is MIT-licensed by Alexey Khit.
> Use at your own risk.

## What you get

- The full go2rtc dashboard (WebRTC / MSE / RTSP players, config editor,
  stream stats) served from the camera on port `1984`.
- An RTSP server on `8554` and WebRTC on `8555`.
- Runs as the unprivileged ACAP user (no root required).
- Config is stored on the device and survives restarts; it is removed on
  uninstall.

## Ports

| Service | Port | URL |
|---|---|---|
| Web UI / HTTP API | `1984` | `http://<camera-ip>:1984/` |
| RTSP server | `8554` | `rtsp://<camera-ip>:8554/<stream>` |
| WebRTC | `8555` | TCP/UDP |

These ports are reachable on the camera's network interface.

> **Security:** by default the Web UI / API on `1984` has no authentication.
> go2rtc can run shell commands through its source modules, so an open API is
> effectively remote access to the device. Before exposing the app beyond a
> trusted network, set `username` / `password` under `api:` in
> `app/go2rtc.yaml` (and `rtsp:` if you serve RTSP), and prefer a dedicated
> limited-privilege device account over `root` in your stream URLs.

## Build

Requires Docker. The go2rtc release binary is downloaded at build time, so no
binaries are committed here.

```sh
./build.sh                      # builds aarch64 and armv7hf
ARCHS="aarch64" ./build.sh      # single architecture
GO2RTC_VERSION=v1.9.14 ./build.sh
```

The resulting `go2rtc_*_<arch>.eap` files are copied into the project root.

Pick the architecture that matches your camera's chip:

| Architecture | Axis chips (examples) |
|---|---|
| `aarch64` | ARTPEC-7/8/9 (64-bit), CV25 |
| `armv7hf` | ARTPEC-6/7 (32-bit), older devices |

## Install

1. Camera web UI → **Apps** → **Add app** → upload the `.eap`.
2. Start the app.
3. Click **Open** (or browse to `http://<camera-ip>:1984/`).
4. Add streams from the dashboard's **Config** tab. For the camera's own
   stream, use a local RTSP URL:

   ```yaml
   streams:
     camera: rtsp://USER:PASS@127.0.0.1:554/axis-media/media.amp
   ```

## How it works

| File | Role |
|---|---|
| `app/manifest.json` | ACAP metadata; `architecture` is stamped in at build time. |
| `app/supervisor.c` | Tiny ACAP main executable (`go2rtc`). Launches the run script, restarts it if it dies, forwards `SIGTERM` for a clean stop. |
| `app/go2rtc_run` | Seeds the default config into `localdata/` on first run, then `exec`s the go2rtc binary. |
| `app/go2rtc.yaml` | Default config, copied to the persistent `localdata/` dir once. |
| `app/lib/go2rtc` | go2rtc binary, downloaded during the Docker build. |
| `app/html/index.html` | Settings page with a link to the dashboard. |

## Notes

- WebRTC works best on the local network. For external access, port `8555`
  (TCP/UDP) must be reachable, or configure a TURN server in go2rtc.
- To serve the dashboard under the camera's own web server suburl instead of
  port `1984`, set `api.base_path` in `go2rtc.yaml` and add a `reverseProxy`
  entry to the manifest. Left out by default to keep direct access simple.

## Credits and license

This project packages [go2rtc](https://github.com/AlexxIT/go2rtc) by Alexey
Khit (MIT). The go2rtc binary is downloaded at build time and its license is
bundled in the package as `lib/go2rtc.LICENSE`; see [NOTICE.md](NOTICE.md) for
attribution.

The packaging in this repository is MIT-licensed (see [LICENSE](LICENSE)).
