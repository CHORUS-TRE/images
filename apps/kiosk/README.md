# Kiosk

Single-app Chromium kiosk — opens a target URL in app mode (no address bar, no
window chrome) for controlled web access. Built on
[ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium-portablelinux).

The kiosk launches with the URL in `BROWSER_URL` (defaults to
`https://www.chorus-tre.ch`). If `IDP_SL_TOKEN` and `IDP_JWT_URL` are
set, the kiosk performs a headless JWT-for-session-cookie exchange before
opening the main window, to pre-authenticate the user into an internal service.
