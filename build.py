#!/usr/bin/env python3
"""
Unified build script for Chorus container images.

Usage:
    python build.py vscode              # Build by app name
    python build.py ./apps/vscode       # Build by path
    python build.py server              # Build server
    python build.py app-init            # Build app-init
    python build.py vscode --dry-run    # Show command without executing
    python build.py --list              # List all available apps

Environment variables:
    REGISTRY    - Container registry (default: harbor.build.chorus-tre.local)
    REPOSITORY  - Repository name (default: apps)
    CACHE       - Cache repository name (default: cache)
    TARGET_ARCH - Target architecture (default: linux/amd64)
    OUTPUT      - Output type: docker, registry (default: docker)
"""

import argparse
import sys
from pathlib import Path

from buildtools import AppConfig, BuildConfig, ImageBuilder, find_app_dir, list_all_apps


# Exit codes
EXIT_SUCCESS = 0
EXIT_BUILD_FAILED = 1
EXIT_CONFIG_ERROR = 2
EXIT_MISSING_FILES = 3


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build Chorus container images",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )

    parser.add_argument("app", nargs="?", help="App name (e.g., vscode) or path (e.g., ./apps/vscode)")
    parser.add_argument("-r", "--registry", help="Container registry (overrides REGISTRY env var)")
    parser.add_argument("--repository", help="Repository name (overrides REPOSITORY env var)")
    parser.add_argument("--cache", help="Cache repository name (overrides CACHE env var)")
    parser.add_argument("--arch", help="Target architecture (overrides TARGET_ARCH env var)")
    parser.add_argument("--output", choices=["docker", "registry"], help="Output type (overrides OUTPUT env var)")
    parser.add_argument("--dry-run", action="store_true", help="Print commands without executing")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")
    parser.add_argument("--list", action="store_true", help="List all available apps")

    args = parser.parse_args()

    # Determine images directory (where this script lives)
    images_dir = Path(__file__).parent.resolve()

    # Handle --list
    if args.list:
        apps = list_all_apps(images_dir)
        print("Available apps:")
        for app in apps:
            print(f"  {app}")
        return EXIT_SUCCESS

    # Require app argument
    if not args.app:
        parser.error("the following arguments are required: app")

    # Find app directory
    app_dir = find_app_dir(args.app, images_dir)
    if not app_dir:
        print(f"Error: App not found: {args.app}", file=sys.stderr)
        print(f"Use --list to see available apps", file=sys.stderr)
        return EXIT_MISSING_FILES

    # Check for labels file
    if not (app_dir / "labels").exists():
        print(f"Error: Labels file not found: {app_dir / 'labels'}", file=sys.stderr)
        return EXIT_MISSING_FILES

    # Create configurations
    try:
        app_config = AppConfig.from_path(app_dir)
    except Exception as e:
        print(f"Error: Failed to configure app: {e}", file=sys.stderr)
        return EXIT_CONFIG_ERROR

    # Build config from environment with CLI overrides
    build_config = BuildConfig()
    if args.registry:
        build_config.registry = args.registry
    if args.repository:
        build_config.repository = args.repository
    if args.cache:
        build_config.cache = args.cache
    if args.arch:
        build_config.target_arch = args.arch
    if args.output:
        build_config.output = args.output

    # Create builder and run
    builder = ImageBuilder(
        app_config=app_config,
        build_config=build_config,
        dry_run=args.dry_run,
        verbose=args.verbose,
    )

    try:
        success = builder.build()
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        return EXIT_MISSING_FILES
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        return EXIT_CONFIG_ERROR
    except Exception as e:
        print(f"Error: Build failed: {e}", file=sys.stderr)
        return EXIT_BUILD_FAILED

    return EXIT_SUCCESS if success else EXIT_BUILD_FAILED


if __name__ == "__main__":
    sys.exit(main())
