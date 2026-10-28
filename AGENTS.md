# Repository status and contributor guide

Status is a configuration snapshot, not a statement about the live machines.
Last reviewed: **2026-10-28** for rin's RDP-only XFCE desktop configuration,
based on parent commit `d920387`. Refresh this section
when the declared host topology, inputs, or pending work changes.

## Current repository state

The flake targets `x86_64-linux` and discovers all host directories, currently
producing `emilia`, `kagura-notebook`, and `rin` configurations. Shared NixOS
defaults are in `common.nix`; shared user configuration is managed by Home
Manager in `home/`.

| Input | Declared channel | Locked revision | Lock timestamp |
| --- | --- | --- | --- |
| `nixpkgs` | `nixos-unstable` | `02c087f3fe673c9e317f206a627cb6b910336dbe` | 2026-10-20 |
| `nixpkgs-stable` | `nixos-25.11` | `b6018f87da91d19d0ab4cf979885689b469cdd41` | 2026-06-30 |
| `home-manager-nixos` | `master`, follows `nixpkgs` | `ec80131710bffcdf3b8498cf41f3a0579833b023` | 2026-10-20 |
| `niri` | `sodiboo/niri-flake`, follows `nixpkgs` | `9ee3e13b60643448228353097880521658b2fe0e` | 2026-08-04 |
| `kagura-pkgs` | `icewithcola/nur-packages`, follows `nixpkgs` | `89c945a556915c18fa75d722d2c32f6bc75a5ae2` | 2026-07-16 |
| `agenix` | `ryantm/agenix` | `5e5b88a0c8e56f291a108c2fe9934054d9745b2e` | 2026-10-20 |

`pkgs` always refers to the rolling `nixos-unstable` input. `pkgs-stable` is
imported only for intentional compatibility pins; today it supplies
`telegram-desktop` on `kagura-notebook`. The notebook also pins
`kagura-pkgs.google-chrome-138`; do not replace either without testing the
reason the pin exists.

`nix flake check --no-build` passed for all three hosts at this snapshot. The
working tree was clean before the emilia disk-footprint reduction. This document
replaces the former `GEMINI.md`.

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

- Intel server with an RDP-only XFCE desktop using systemd-boot and the
  regular kernel. `/` is ext4; `/mnt/ssd128` is Btrfs (`nofail`, `noatime`,
  `compress=zstd:3`) and is scrubbed weekly. `/tmp` is tmpfs and zram is disabled.
- xrdp listens on TCP 3389 and starts XFCE with a dedicated D-Bus session.
  The local X server and graphical login remain disabled. RDP uses existing
  system-account passwords; no credentials are declared here.
- NetworkManager owns bridge `br-cm` and enslaves `enp8s0`; do not alter those
  settings remotely without a confirmed recovery path. The global firewall is
  disabled; Tailscale enables nftables and trusts `tailscale0` when routing.
- Runs SSH, Docker (rootless support enabled), libvirt, Incus bridged to
  `br-cm`, qBittorrent Enhanced nox, nginx, Home Assistant, Tailscale, DDNS,
  DN42/BIRD2, the NVIDIA container toolkit, and daily Immich rsync backup from
  `/opt/immich-app/library/` to `/mnt/ssd128/immich/library`.
- Home Assistant's internal/default URL is `https://ha.home.lolicon.cyou`.
  nginx listens on `192.168.114.167:443` and proxies to the loopback-only
  backend at `127.0.0.1:18123`; Tailscale clients use the advertised LAN route.
- Home Assistant 2026.8 ignores HTTP YAML after its one-time migration. The
  host module therefore manages `.storage/http` before service startup; keep
  listener and trusted-proxy changes in that generated storage record.
- Home Assistant includes Xiaomi's official `xiaomi_home` custom integration.
  Version 0.4.7 still hardcodes an OAuth callback to `homeassistant.local`,
  which is intentionally not exposed by the nginx configuration.
- The Nix-managed `Kagura's home` YAML dashboard is colocated with the host
  module in `hosts/rin/host-specific/home-assistant/`. The `机柜` section is
  monitoring-only and must never expose a power-off or other writable entity.
- The adjacent `openwrt-traffic.nix` module polls the router at `192.168.114.1`
  over certificate-pinned ubus HTTPS using a read-only RPC account. Its password
  is agenix-managed for `hass`, encrypted only to rin's existing `kagura-nas`
  recipient. The dashboard's `网络` view shows WAN rates and daily/monthly usage.
- Runs the local `clash_config/proxy-checker/run.sh` as `kagura` with a Home
  Manager user timer, hourly and five minutes after the user manager starts.
  Checks use `br-cm`; successful runs upload combined selections to Cloudflare
  KV using the checkout's runtime `.env`. User lingering keeps it running after
  logout.
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
  node on port 32457.
- The iSCSI fileio backing image at `/mnt/data/iscsi.img` is configured as
  200 GiB, matching its existing size on the server.
- Uses the NixOS minimal profile and a host-specific Home Manager package list
  retaining terminal, monitoring, GnuPG, and network tools, without Kitty,
  fonts, Yazi, Hyfetch, or manuals. Other hosts retain the shared package sets.
- Nixpkgs remains pinned in the system registry by GitHub revision/hash rather
  than a store path, allowing unused source trees to be collected. Registry
  lookups may fetch the pinned source on demand.
- Collects garbage daily with seven-day generation retention, optimises the
  store daily, and triggers additional collection below 512 MiB free (aiming
  for 1 GiB). The persistent journal is capped at 100 MiB and stops growing
  below 512 MiB free; the runtime journal is capped at 32 MiB.
- Local builds before/after this change measured runtime closures of
  2.32 GiB / 1.57 GiB (32.6% smaller). This does not measure the live store;
  old generations and other GC roots retain paths until collected.

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
