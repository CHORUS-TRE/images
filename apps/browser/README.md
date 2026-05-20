# Browser

Open-source Chromium web browser with a visible address bar. Built on
[ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium-portablelinux).

## Environment variables

| Variable | Default | Effect |
|---|---|---|
| `BROWSER_URL` | `about:blank` | URL to open in the main window. |
| `BROWSER_JWT_URL` | unset | Backend endpoint that exchanges a JWT (passed in the URL fragment) for a session cookie. When set together with `BROWSER_JWT_TOKEN`, the browser performs a headless exchange before opening the main window, to pre-authenticate the user into an internal service. |
| `BROWSER_JWT_TOKEN` | unset | JWT used in the headless exchange against `BROWSER_JWT_URL`. Both must be set; neither does anything alone. |
