# Workspace Rules

## NixOS Configuration Validation

- **Always run `nix flake check` before committing and pushing changes.** Do not tell the user the work is done until `nix flake check` passes successfully.
- If `nix flake check` fails, fix the issue and re-check before committing.
