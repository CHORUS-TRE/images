"""Utility functions for build system."""

import base64
import shutil
import subprocess
import sys
from contextlib import contextmanager
from pathlib import Path
from typing import Generator, Optional

# Maximum logo file size (48KB) - Docker labels max at 65,518 bytes
# Base64 encoding adds ~33%, plus data URI prefix
MAX_LOGO_SIZE_BYTES = 48 * 1024  # 48KB


def validate_logo_size(logo_path: Path) -> None:
    """Validate logo file size is within Docker label limits.

    Raises:
        ValueError: If logo exceeds maximum size
    """
    size = logo_path.stat().st_size
    if size > MAX_LOGO_SIZE_BYTES:
        raise ValueError(
            f"Logo file too large: {size:,} bytes (max {MAX_LOGO_SIZE_BYTES:,} bytes / 48KB). "
            f"Docker labels are limited to 65,518 bytes and base64 encoding adds ~33%. "
            f"Please reduce the logo size."
        )


def encode_logo_to_base64(logo_path: Path) -> str:
    """Convert a PNG logo to a base64 data URI."""
    with open(logo_path, "rb") as f:
        logo_data = f.read()
    b64_data = base64.b64encode(logo_data).decode("ascii")
    return f"data:image/png;base64,{b64_data}"


@contextmanager
def copy_core_directory(
    core_source: Path,
    app_dir: Path,
    verbose: bool = False,
) -> Generator[Path, None, None]:
    """Context manager to copy core directory and clean up on exit.

    Args:
        core_source: Path to the core directory to copy from
        app_dir: Path to the app directory to copy into
        verbose: Whether to print status messages

    Yields:
        Path to the copied core directory
    """
    core_dest = app_dir / "core"

    if not core_source.exists():
        raise FileNotFoundError(f"Core directory not found: {core_source}")

    try:
        if verbose:
            print(f"  Copying core directory from {core_source}")
        shutil.copytree(core_source, core_dest)
        yield core_dest
    finally:
        if core_dest.exists():
            if verbose:
                print(f"  Cleaning up core directory")
            shutil.rmtree(core_dest)


def run_command(
    cmd: list[str],
    dry_run: bool = False,
    verbose: bool = False,
    check: bool = True,
) -> subprocess.CompletedProcess:
    """Run a command with optional dry-run mode.

    Args:
        cmd: Command and arguments as a list
        dry_run: If True, print command but don't execute
        verbose: If True, print command before executing
        check: If True, raise exception on non-zero exit code

    Returns:
        CompletedProcess object (or dummy for dry-run)
    """
    if dry_run or verbose:
        print(f"  $ {' '.join(cmd)}")

    if dry_run:
        return subprocess.CompletedProcess(cmd, 0)

    return subprocess.run(cmd, check=check)


def find_app_dir(app_name_or_path: str, images_dir: Path) -> Optional[Path]:
    """Find the app directory from a name or path.

    Args:
        app_name_or_path: Either an app name (e.g., "vscode") or a path
        images_dir: Path to the images directory

    Returns:
        Resolved path to the app directory, or None if not found
    """
    # If it's a path (contains / or .), resolve it
    if "/" in app_name_or_path or app_name_or_path.startswith("."):
        path = Path(app_name_or_path).resolve()
        if path.is_dir() and (path / "labels").exists():
            return path
        return None

    # Otherwise, search for the app by name
    # Check special locations first
    for special in ["server", "app-init"]:
        if app_name_or_path == special:
            path = images_dir / special
            if path.is_dir() and (path / "labels").exists():
                return path

    # Check apps/ directory
    path = images_dir / "apps" / app_name_or_path
    if path.is_dir() and (path / "labels").exists():
        return path

    return None


def list_all_apps(images_dir: Path) -> list[str]:
    """List all available app names.

    Args:
        images_dir: Path to the images directory

    Returns:
        Sorted list of app names
    """
    apps = []

    # Check special locations
    for special in ["server", "app-init"]:
        path = images_dir / special
        if path.is_dir() and (path / "labels").exists():
            apps.append(special)

    # Check apps/ directory
    apps_dir = images_dir / "apps"
    if apps_dir.is_dir():
        for app_path in apps_dir.iterdir():
            if app_path.is_dir() and (app_path / "labels").exists():
                apps.append(app_path.name)

    return sorted(apps)
