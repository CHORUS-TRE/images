"""Labels file parsing for build configuration."""

from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional


@dataclass
class ParsedLabels:
    """Parsed labels from labels file(s)."""
    app_version: str
    pkg_rel: str
    cache_mode: str = "max"
    build_args: dict[str, str] = field(default_factory=dict)
    image_labels: dict[str, str] = field(default_factory=dict)
    has_icon_label: bool = False

    @property
    def version(self) -> str:
        """Get full version string."""
        return f"{self.app_version}-{self.pkg_rel}"


class LabelsParser:
    """Parser for labels files."""

    BUILD_ARG_PREFIX = "ch.chorus-tre.build.arg."
    BUILD_METADATA_PREFIX = "ch.chorus-tre.build."
    ICON_LABEL = "ch.chorus-tre.app.icon"
    KIOSK_CONFIG_URL_PREFIX = "ch.chorus-tre.app.kiosk-config-url."

    def __init__(self, labels_file: Path, kiosk_apps_dir: Optional[Path] = None):
        self.labels_file = labels_file
        self.kiosk_apps_dir = kiosk_apps_dir

    def parse(self) -> ParsedLabels:
        """Parse labels file(s) and return structured data."""
        if not self.labels_file.exists():
            raise FileNotFoundError(f"Labels file not found: {self.labels_file}")

        # Parse main labels file
        raw_labels = self._parse_file(self.labels_file)

        # Extract required build configuration
        app_version = raw_labels.get("ch.chorus-tre.build.app-version")
        pkg_rel = raw_labels.get("ch.chorus-tre.build.pkg-rel")
        cache_mode = raw_labels.get("ch.chorus-tre.build.cache-mode", "max")

        if not app_version:
            raise ValueError("Missing 'ch.chorus-tre.build.app-version' in labels")
        if not pkg_rel:
            raise ValueError("Missing 'ch.chorus-tre.build.pkg-rel' in labels")

        # Separate build args, metadata, and image labels
        build_args: dict[str, str] = {}
        image_labels: dict[str, str] = {}
        has_icon_label = False

        for key, value in raw_labels.items():
            if key.startswith(self.BUILD_ARG_PREFIX):
                arg_name = key[len(self.BUILD_ARG_PREFIX):]
                build_args[arg_name] = value
            elif key.startswith(self.BUILD_METADATA_PREFIX):
                # Skip build metadata (not image labels)
                continue
            elif key == self.ICON_LABEL:
                # Icon label handled separately (logo.png)
                has_icon_label = True
            else:
                image_labels[key] = value

        # Process kiosk apps directory if present
        if self.kiosk_apps_dir and self.kiosk_apps_dir.is_dir():
            kiosk_labels = self._parse_kiosk_apps()
            image_labels.update(kiosk_labels)

        return ParsedLabels(
            app_version=app_version,
            pkg_rel=pkg_rel,
            cache_mode=cache_mode,
            build_args=build_args,
            image_labels=image_labels,
            has_icon_label=has_icon_label,
        )

    def _parse_file(self, path: Path) -> dict[str, str]:
        """Parse a single labels file into key-value pairs."""
        labels: dict[str, str] = {}

        with open(path, "r") as f:
            for line in f:
                line = line.strip()
                # Skip empty lines and comments
                if not line or line.startswith("#"):
                    continue

                # Split on first = only
                if "=" not in line:
                    continue

                key, value = line.split("=", 1)
                key = key.strip()
                value = value.strip()

                # Remove surrounding quotes if present
                value = self._unquote(value)

                if key:
                    labels[key] = value

        return labels

    def _unquote(self, value: str) -> str:
        """Remove surrounding quotes from a value."""
        if len(value) >= 2:
            if (value.startswith('"') and value.endswith('"')) or \
               (value.startswith("'") and value.endswith("'")):
                return value[1:-1]
        return value

    def _parse_kiosk_apps(self) -> dict[str, str]:
        """Parse kiosk apps labels files and transform keys."""
        if not self.kiosk_apps_dir:
            return {}

        kiosk_labels: dict[str, str] = {}

        # Get all files in apps/ directory, sorted
        app_files = sorted(self.kiosk_apps_dir.iterdir())

        for app_file in app_files:
            if not app_file.is_file():
                continue

            kiosk_name = app_file.name
            raw_labels = self._parse_file(app_file)

            for key, value in raw_labels.items():
                if key.startswith(self.KIOSK_CONFIG_URL_PREFIX):
                    # Transform: ch.chorus-tre.app.kiosk-config-url.X
                    #        -> ch.chorus-tre.app.kiosk-config-url.KIOSK_NAME.X
                    suffix = key[len(self.KIOSK_CONFIG_URL_PREFIX):]
                    new_key = f"{self.KIOSK_CONFIG_URL_PREFIX}{kiosk_name}.{suffix}"
                    kiosk_labels[new_key] = value
                else:
                    # Other labels pass through as-is
                    kiosk_labels[key] = value

        return kiosk_labels
