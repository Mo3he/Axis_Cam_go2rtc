# Changelog

All notable changes to this project are documented here. Each version
links to its full release notes on GitHub.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [1.9.14-Signed] - 2026-07-21 - go2rtc 1.9.14 (Signed)

- Packages are now signed with the Axis ACAP signing service and install
  normally on AXIS OS 12.10 and later.
- Vendor updated to `moshe@mohome.net` with the registered vendor ID.
- Upgrading from an earlier unsigned version can fail with "Couldn't
  install: app" (device log: "Vendor ID in manifest does not match the
  vendor ID of the previous version"). Back up your config, uninstall the
  old version, then install this one.

## [1.9.14-1] - 2026-07-07 - go2rtc 1.9.14-1 (AXIS OS 13 ready)

## [1.9.14] - 2026-06-26 - go2rtc ACAP 1.9.14

[1.9.14-1]: https://github.com/Mo3he/Axis_Cam_go2rtc/releases/tag/v1.9.14-1
[1.9.14]: https://github.com/Mo3he/Axis_Cam_go2rtc/releases/tag/v1.9.14
