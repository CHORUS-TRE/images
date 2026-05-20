# Browser

General-purpose Chromium browser with a visible address bar. Built on
[ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium-portablelinux).

The browser launches with `about:blank` by default. Set `BROWSER_URL` to land on a
specific page. If `BROWSER_JWT_TOKEN` and `BROWSER_JWT_URL` are set, the browser
performs a headless JWT-for-session-cookie exchange before opening the main window,
to pre-authenticate the user into an internal service.
