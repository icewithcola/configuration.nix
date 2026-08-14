# Repository status and contributor guide

Status is a configuration snapshot, not a statement about the live machines.
Last reviewed: **2026-08-14** at base commit
`43488187a85ffc5adb4d684a18463fcc26a4312b` (`rin: enable deep CPU idle
states`). Refresh this section when the declared host topology, inputs, or
pending work changes.

## Current repository state

The flake targets `x86_64-linux` and discovers all host directories, currently
producing `emilia`, `kagura-notebook`, and `rin` configurations. Shared NixOS
defaults are in `common.nix`; shared user configuration is managed by Home
Manager in `home/`.

| Input | Declared channel | Locked revision | Lock timestamp |
| --- | --- | --- | --- |
| `nixpkgs` | `nixos-unstable` | `2fcb964de67fcf60b43471c55d5d99e61a9ccb5a` | 2026-08-10 |
| `nixpkgs-stable` | `nixos-25.11` | `b6018f87da91d19d0ab4cf979885689b469cdd41` | 2026-06-30 |
| `home-manager-nixos` | `master`, follows `nixpkgs` | `f8badd57bac448d07fb93a7884a207ecb0927e95` | 2026-08-12 |
| `niri` | `sodiboo/niri-flake`, follows `nixpkgs` | `9ee3e13b60643448228353097880521658b2fe0e` | 2026-08-04 |
| `kagura-pkgs` | `icewithcola/nur-packages`, follows `nixpkgs` | `89c945a556915c18fa75d722d2c32f6bc75a5ae2` | 2026-07-16 |
| `agenix` | `ryantm/agenix` | `b027ee29d959fda4b60b57566d64c98a202e0feb` | 2026-02-04 |

`pkgs` always refers to the rolling `nixos-unstable` input. `pkgs-stable` is
imported only for intentional compatibility pins; today it supplies
`telegram-desktop` on `kagura-notebook`. The notebook also pins
`kagura-pkgs.google-chrome-138`; do not replace either without testing the
reason the pin exists.

`nix flake check --no-build` passed for all three hosts at this snapshot. The
working tree deliberately has a pending change in
`hosts/rin/host-specific/nginx.nix`: the `store` virtual host has been changed
from direct qBittorrent-download serving to a proxy for `127.0.0.1:18080`.
Preserve and review that separate change unless the task concerns it. This
document replaces the former `GEMINI.md`.

## Declared host topology

### `kagura-notebook`

- Btrfs root with separate `/.snapshots`, `/home`, and `/var/log` subvolumes;
  weekly Btrfs scrub and zram are enabled.
- Uses `linuxPackages_latest`, systemd-boot, NetworkManager, and the
  Qualcomm connectivity-check URL. Its global firewall is disabled.
- Is the GUI/development machine: SDDM on Wayland, Plasma 6, Niri, Fcitx5,
  PipeWire, Bluetooth, Steam, Docker, Incus, libvirt and virt-manager.
- Home Manager enables the GUI, development, and network package sets.
- Tailscale is a client in the `dace-teeth` tailnet. Its auth key comes from
  agenix.

### `rin`

- Headless Intel server using systemd-boot and the regular kernel. `/` is
  ext4; `/mnt/ssd128` is Btrfs (`nofail`, `noatime`, `compress=zstd:3`) and is
  scrubbed weekly. `/tmp` is tmpfs and zram is disabled.
- NetworkManager owns bridge `br-cm` and enslaves `enp8s0`; do not alter those
  settings remotely without a confirmed recovery path. The global firewall is
  disabled; Tailscale enables nftables and trusts `tailscale0` when routing.
- Runs SSH, Docker (rootless support enabled), libvirt, Incus bridged to
  `br-cm`, qBittorrent Enhanced nox, nginx, Tailscale, DDNS, DN42/BIRD2, the
  NVIDIA container toolkit, and daily Immich rsync backup from
  `/opt/immich-app/library/` to `/mnt/ssd128/immich/library`.
- Is a Tailscale exit node and advertises `192.168.114.0/24` and `fd00::/8`.
  nginx includes Tailscale-only HTTPS listener(s), waits for `tailscale0`, and
  uses agenix TLS material. DN42 uses WireGuard peers and BIRD route filters.
- Uses `nvidiaPackages.legacy_580`, a custom `memmap` boot parameter, and a
  oneshot service enabling C3/C6 CPU idle states. Treat kernel, driver, and
  boot changes as one compatibility unit.

### `emilia`

- Headless VPS using GRUB on `/dev/vda`, ext4 root, static IPv4/IPv6 on
  `ens18`, and no global firewall.
- Runs SSH, iSCSI configuration, and Tailscale as a tagged global relay/exit
  node on port 32457. Its Home Manager setup enables only the network package
  set.

## Where to make changes

| Area | Location |
| --- | --- |
| Flake inputs, overlays, host generation | `flake.nix`, `flake.lock` |
| System defaults and baseline packages | `common.nix` |
| Host assembly and hardware/network/boot options | `hosts/<host>/` |
| Shared custom NixOS options | `nixosOptions/` |
| Shared NixOS services/programs | `services/`, `programs/` |
| Home Manager package groups and terminal config | `home/` |
| Niri, Waybar, and Fuzzel modules | `homeModules/`, `nixosModules/niri/` |
| Agenix declarations and encrypted secrets | `secrets/` |

Keep a change host-specific unless at least two hosts genuinely need the same
behaviour. Prefer native NixOS/Home Manager options and `lib.getExe` in unit
scripts over imperative setup.

## Safe workflow

Before modifying a host, inspect both its `default.nix` and
`configuration.nix`, along with any imported `host-specific` module. Do not
discard unrelated worktree changes. Format edited Nix files with `nix fmt`.

Use the narrowest suitable validation command:

```sh
nix flake check --no-build                    # evaluate all hosts
nix eval .#nixosConfigurations.<host>.config.system.build.toplevel
nixos-rebuild dry-build --flake .#<host>      # validate a target without activation
git diff --check
```

Never run `nixos-rebuild switch` or update the entire lock file unless the task
explicitly authorizes deployment or a full dependency refresh. For a deliberate
single-input upgrade, run `nix flake lock --update-input <input>`, inspect the
lock diff and release notes, then dry-build each affected host.

## Guardrails

- Never add decrypted credentials, Age private keys, API tokens, or TLS keys.
  Use the existing agenix flow and confirm every intended recipient.
- Treat changes to SSH, Tailscale, DN42, DDNS, nginx listeners, bridge
  topology, firewalls, boot loaders, filesystems, kernel parameters, NVIDIA,
  or storage mounts as outage-risking. Preserve an independent access path to
  a remote host before deployment.
- Build/test kernel, NVIDIA, Niri/Plasma, Incus/Docker, and package-set updates
  per host; their failures can be host-specific even though the flake evaluates.
