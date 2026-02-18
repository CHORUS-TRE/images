# Localizer (Windows via Wine)

Windows version of Localizer running via Wine.

## Overview

This container runs the Windows build of Localizer using Wine64. This may be useful when:
- Testing Windows-specific features
- The Linux version has issues on certain systems
- Specific Windows behavior is required

## Version

- Localizer: 4.4.5
- Wine: System default (Ubuntu 24.04)

## Notes

- Wine prefix is created per-user at runtime in `~/.wine`
- First launch may take slightly longer due to Wine initialization
- Some minor visual differences may occur compared to native Windows
- Wine debug output is suppressed (`WINEDEBUG="-all"`)
