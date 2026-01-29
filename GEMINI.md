# Kagura's NixOS Configuration

This repository contains the NixOS configuration for Kagura's infrastructure, managed as a Nix Flake. It supports multiple hosts with varying roles (GUI, headless, dev) and manages user environments via Home Manager.

## Project Structure

- **`flake.nix`**: The entry point. Defines inputs (nixpkgs, home-manager, agenix, etc.) and outputs (host configurations).
- **`hosts/`**: Contains configuration for each machine.
    - Each host (e.g., `rin`, `emilia`) has a directory.
    - `default.nix`: The main system configuration for the host.
    - `home.nix`: Host-specific Home Manager configuration.
    - `configuration.nix`: Standard NixOS hardware/boot/networking settings.
- **`home/`**: Shared Home Manager configuration (`default.nix`, `packages.nix`, etc.).
- **`services/`**: Custom NixOS service modules (e.g., `dn42.nix`, `sshd.nix`, `docker.nix`).
- **`programs/`**: Custom program configurations.
- **`nixosOptions/`**: Custom NixOS options definitions.
- **`secrets/`**: Encrypted secrets managed by `agenix`.
- **`common.nix`**: Global configuration shared across all hosts.

## Key Technologies

- **NixOS Flakes**: For reproducible and declarative system configuration.
- **Home Manager**: For managing user environments.
- **Agenix**: For secure secret management using Age encryption.
- **Niri**: A Wayland scrollable tiling compositor.
- **DN42**: Configuration for the decentralized network, including BIRD2 and WireGuard setup.

## Targets

As defined in the project:
- **gui**: Standard desktop environment.
- **gui + dev**: Desktop environment with development tools.
- **headless**: Server environment without a GUI.

## Building and Deployment

To rebuild the system for the current host:

```bash
sudo nixos-rebuild switch --flake .
```

To rebuild for a specific host (e.g., `rin`):

```bash
sudo nixos-rebuild switch --flake .#rin
```

To update the flake inputs:

```bash
nix flake update
```

## Development Guidelines

1.  **Validate Changes**: Always evaluate the Nix configuration to ensure validity after making changes.
    *   Use `nix flake check` to verify the integrity of the flake.
    *   Use `nixos-rebuild dry-build --flake .#<host>` or `nix eval .#nixosConfigurations.<host>.config.system.build.toplevel` to check specific host configurations without applying them.
2.  **Critical Components**: Exercise extreme caution when modifying system-critical components such as:
    *   **Firewall rules** (`networking.firewall`, `services.bird`, etc.) - Risk of locking out access.
    *   **Kernel configuration** (`boot.kernel*`) - Risk of boot failures.
    *   **Network interfaces** - Risk of connectivity loss.
    *   **Authentication/Secrets** (`services.sshd`, `agenix`, `users`) - Security risks or lockout.
    *   **Always review context** before editing these files.