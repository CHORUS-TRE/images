"""Docker buildx orchestration for image builds."""

import subprocess
from pathlib import Path
from typing import Optional

from .config import AppConfig, BuildConfig
from .labels import LabelsParser, ParsedLabels
from .utils import copy_core_directory, encode_logo_to_base64, run_command, validate_logo_size


class ImageBuilder:
    """Orchestrates Docker image builds."""

    def __init__(self, app_config: AppConfig, build_config: BuildConfig, dry_run: bool = False, verbose: bool = False):
        self.app_config = app_config
        self.build_config = build_config
        self.dry_run = dry_run
        self.verbose = verbose
        self._labels = None

    @property
    def labels(self) -> ParsedLabels:
        """Get parsed labels (cached)."""
        if self._labels is None:
            parser = LabelsParser(self.app_config.labels_file, self.app_config.kiosk_apps_dir)
            self._labels = parser.parse()
        return self._labels

    @property
    def image_tag(self) -> str:
        """Get full image tag."""
        return f"{self.build_config.registry}/{self.build_config.repository}/{self.app_config.app_name}:{self.labels.version}"

    @property
    def cache_tag(self) -> str:
        """Get cache tag base."""
        return f"{self.build_config.registry}/{self.build_config.cache}/{self.app_config.app_name}-{self.build_config.cache}"

    def ensure_builder_exists(self) -> None:
        """Create buildx builder if it doesn't exist."""
        result = subprocess.run(["docker", "buildx", "inspect", self.build_config.builder_name], capture_output=True)

        if result.returncode != 0:
            if self.verbose:
                print(f"  Creating builder: {self.build_config.builder_name}")
            run_command(
                [
                    "docker", "buildx", "create",
                    "--name", self.build_config.builder_name,
                    "--driver", "docker-container",
                ],
                dry_run=self.dry_run,
                verbose=self.verbose,
            )

    def build_cache_args(self) -> list[str]:
        """Build cache arguments based on output type."""
        args = []
        version = self.labels.version
        cache_mode = self.labels.cache_mode

        if self.build_config.is_registry_output:
            # Registry cache
            args.extend([
                f"--cache-from=type=registry,ref={self.cache_tag}:{version}",
                f"--cache-from=type=registry,ref={self.cache_tag}:latest",
                f"--cache-to=type=registry,ref={self.cache_tag}:{version},mode={cache_mode},image-manifest=true",
                f"--cache-to=type=registry,ref={self.cache_tag}:latest,mode={cache_mode},image-manifest=true",
            ])
        else:
            # Local cache
            cache_dir = Path("/tmp/.buildx-cache")
            if not self.dry_run:
                cache_dir.mkdir(parents=True, exist_ok=True)
            args.extend([
                f"--cache-from=type=local,src={cache_dir}",
                f"--cache-to=type=local,dest={cache_dir}",
            ])

        return args

    def build_label_args(self, icon_base64: Optional[str] = None) -> list[str]:
        """Build label arguments for docker build."""
        args = []
        version = self.labels.version
        app_version = self.labels.app_version

        # Add labels from labels file
        for key, value in self.labels.image_labels.items():
            args.append(f"--label={key}={value}")

        # Add icon label if logo exists and icon label was in labels file
        if icon_base64 and self.labels.has_icon_label:
            args.append(f"--label=ch.chorus-tre.app.icon={icon_base64}")

        # Add standard labels
        args.extend([
            f"--label=org.opencontainers.image.version={version}",
            f"--label=ch.chorus-tre.app.name={self.app_config.app_name}",
            f"--label=ch.chorus-tre.app.version={app_version}",
            f"--label=ch.chorus-tre.image.name={self.app_config.app_name}",
            f"--label=ch.chorus-tre.image.tag={version}",
        ])

        return args

    def build_arg_args(self) -> list[str]:
        """Build --build-arg arguments."""
        args = []
        app_version = self.labels.app_version

        # Standard build args
        args.extend([
            f"--build-arg=APP_NAME={self.app_config.app_name}",
            f"--build-arg=APP_VERSION={app_version}",
        ])

        # Extra build args from labels
        for name, value in self.labels.build_args.items():
            args.append(f"--build-arg={name}={value}")

        return args

    def build_docker_command(self, icon_base64: Optional[str] = None) -> list[str]:
        """Build the complete docker buildx command."""
        cmd = [
            "docker", "buildx", "build",
            "--pull",
            "--builder", self.build_config.builder_name,
            f"--platform={self.build_config.target_arch}",
            "-t", self.image_tag,
        ]

        # Add labels
        cmd.extend(self.build_label_args(icon_base64))

        # Add build args
        cmd.extend(self.build_arg_args())

        # Add cache args
        cmd.extend(self.build_cache_args())

        # Add output type
        cmd.append(f"--output={self.build_config.output_type}")

        # Add build context (app directory)
        cmd.append(str(self.app_config.app_dir))

        return cmd

    def print_build_info(self) -> None:
        """Print build information."""
        version = self.labels.version
        print(f"Building {self.app_config.app_name} version {version}")
        print(f"  Registry: {self.build_config.registry}")
        print(f"  Repository: {self.build_config.repository}")
        print(f"  Architecture: {self.build_config.target_arch}")
        print(f"  Cache mode: {self.labels.cache_mode}")

        # Print build args if verbose
        if self.verbose and self.labels.build_args:
            for name, value in self.labels.build_args.items():
                print(f"  Build arg: {name}={value}")

    def build(self) -> bool:
        """Execute the build.

        Returns:
            True if build succeeded, False otherwise
        """
        self.print_build_info()

        # Ensure builder exists
        if not self.dry_run:
            self.ensure_builder_exists()

        # Encode logo if present
        icon_base64 = None
        if self.app_config.has_logo:
            print("  Found logo.png, converting to base64...")
            if not self.dry_run:
                validate_logo_size(self.app_config.logo_file)
                icon_base64 = encode_logo_to_base64(self.app_config.logo_file)

        # Build the docker command
        cmd = self.build_docker_command(icon_base64)

        # Execute build with or without core directory
        if self.app_config.needs_core:
            with copy_core_directory(self.app_config.core_path, self.app_config.app_dir, verbose=self.verbose):
                result = run_command(cmd, dry_run=self.dry_run, verbose=self.verbose, check=False)
        else:
            result = run_command(cmd, dry_run=self.dry_run, verbose=self.verbose, check=False)

        if result.returncode != 0:
            print()
            print(f"Failed to build {self.app_config.app_name}")
            return False

        print()
        print(f"Successfully built {self.image_tag}")
        return True
