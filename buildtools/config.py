"""Configuration dataclasses for build system."""

from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Optional
import os


class AppType(Enum):
    """Type of application being built."""
    STANDARD_APP = "standard_app"  # apps/* - uses ../../core
    APP_INIT = "app_init"          # app-init - uses ../core
    SERVER = "server"              # server - no core, hardcoded name
    KIOSK = "kiosk"                # apps/kiosk - multi-file labels


@dataclass
class BuildConfig:
    """Global build configuration from environment variables."""
    registry: str = field(default_factory=lambda: os.environ.get(
        "REGISTRY", "harbor.build.chorus-tre.local"))
    repository: str = field(default_factory=lambda: os.environ.get(
        "REPOSITORY", "apps"))
    cache: str = field(default_factory=lambda: os.environ.get(
        "CACHE", "cache"))
    target_arch: str = field(default_factory=lambda: os.environ.get(
        "TARGET_ARCH", "linux/amd64"))
    output: str = field(default_factory=lambda: os.environ.get(
        "OUTPUT", "docker"))
    builder_name: str = "docker-container"

    @property
    def output_type(self) -> str:
        """Get docker output type string."""
        return f"type={self.output}"

    @property
    def is_registry_output(self) -> bool:
        """Check if output is to registry."""
        return self.output == "registry"


@dataclass
class AppConfig:
    """Application-specific configuration."""
    app_dir: Path
    app_name: str
    app_type: AppType
    core_path: Optional[Path] = None

    @classmethod
    def from_path(cls, app_path: Path) -> "AppConfig":
        """Create AppConfig by detecting app type from path."""
        app_dir = app_path.resolve()
        dir_name = app_dir.name

        # Detect app type and set appropriate configuration
        if dir_name == "server":
            return cls(app_dir=app_dir, app_name="xpra-server", app_type=AppType.SERVER, core_path=None)
        elif dir_name == "app-init":
            return cls(app_dir=app_dir, app_name=dir_name, app_type=AppType.APP_INIT, core_path=app_dir.parent / "core")
        elif dir_name == "kiosk":
            return cls(app_dir=app_dir, app_name=dir_name, app_type=AppType.KIOSK, core_path=app_dir.parent.parent / "core")
        else:
            # Standard app in apps/
            return cls(app_dir=app_dir, app_name=dir_name, app_type=AppType.STANDARD_APP, core_path=app_dir.parent.parent / "core")

    @property
    def labels_file(self) -> Path:
        """Get path to main labels file."""
        return self.app_dir / "labels"

    @property
    def logo_file(self) -> Path:
        """Get path to logo file."""
        return self.app_dir / "logo.png"

    @property
    def has_logo(self) -> bool:
        """Check if logo file exists."""
        return self.logo_file.exists()

    @property
    def needs_core(self) -> bool:
        """Check if app needs core directory copied."""
        return self.core_path is not None

    @property
    def kiosk_apps_dir(self) -> Optional[Path]:
        """Get kiosk apps directory if this is a kiosk app."""
        if self.app_type == AppType.KIOSK:
            apps_dir = self.app_dir / "apps"
            if apps_dir.is_dir():
                return apps_dir
        return None
