# nixdots Structure Reference

This is a reference for my NixOS configuration. 

## Overview

Each layer has one job, and imports only flow downward: systems pick bundles, bundles pick modules, modules configure one thing. Today the Home Manager half of that wiring sits in `flake.nix` rather than in the system folder.

```
nixdots/
├── flake.nix                     # inputs, numtide cache, one output per machine, HM user imports
├── flake.lock                    # pinned input versions (generated)
│
├── systems/                      # one folder per machine
│   ├── oolong/                   # work desktop (AMD, btrfs)
│   │   ├── default.nix           # picks NixOS bundles + host settings, user account, locale
│   │   └── hardware-configuration.nix
│   ├── laptop/                   # Future
│   └── htpc/                     # Future
│
├── bundles/                      # roles a machine plays
│   ├── nixos/
│   │   ├── common.nix            # flakes + allowUnfree (settings, no imports yet)
│   │   ├── desktop.nix
│   │   └── development.nix
│   └── home/
│       ├── common.nix            # CLI packages (packages, no imports yet)
│       ├── desktop.nix
│       └── development.nix
│
├── modules/                      # building blocks: one feature per file
│   ├── nixos/                    # system level (root, /etc, services)
│   │   ├── hyprland.nix
│   │   ├── localsend.nix
│   │   ├── docker.nix
│   │   ├── 1password.nix
│   │   ├── nix-ld.nix
│   │   ├── llm-cache.nix
│   │   └── skwd-wall.nix         # wallpaper picker + daemon, steamcmd
│   └── home/                     # user level (~/.config, user packages)
│       ├── hyprland/             # a feature with raw config gets a folder
│       │   ├── hyprland.nix
│       │   └── hyprland.lua      # read into HM's hyprland module
│       ├── terminal.nix
│       ├── browser.nix
│       ├── polkit.nix
│       ├── mise.nix
│       ├── neovim.nix
│       ├── git.nix
│       ├── gh.nix
│       ├── ssh.nix
│       └── ai.nix
│
├── users/
│   └── isaac.nix                 # HM identity; true on every machine
│
├── lib/                          # Future: mkHost, when the second machine arrives
└── docs/                         # Future: BOOTSTRAP.md, HANDOFF.md
```

| Layer | Answers the question | May import | Never contains |
| --- | --- | --- | --- |
| `flake.nix` | Which machines exist, and from what inputs? | `systems/`, HM user imports (until `lib/` exists) | Feature config |
| `systems/` | What is this machine and what roles does it play? | `bundles/nixos/`, its own files | Reusable feature config |
| `bundles/` | What goes together for a role? | `modules/` | Real settings (beyond small `mkDefault`s) |
| `modules/` | How is one feature set up? | Files in its own folder, flake inputs passed as args | Host or hardware specifics |
| `users/` | Who is the user, everywhere? | Nothing | Feature config or host specifics |

## flake.nix

The entry point declares four inputs and builds one output, `nixosConfigurations.oolong`. It also holds the Home Manager user imports, which the original plan put in `systems/`.

- Inputs: `nixpkgs` (nixos-unstable), `home-manager` (master, follows nixpkgs), `strata` (lgse/strata), `lazyvim` (pfassina/lazyvim-nix), `llm-agents` (numtide/llm-agents.nix), `nix-flatpak`, `sops-nix` and `skwd-wall` (liixini/skwd-wall, `nix` branch, follows nixpkgs).
- `nixConfig` adds the numtide binary cache so the very first build already uses it; `modules/nixos/llm-cache.nix` adds the same cache to the running system.
- Inputs are passed by name, never the whole `inputs` set. `specialArgs` gives NixOS modules `strata` and `skwd-wall` (latte and oolong only); `extraSpecialArgs` gives HM modules `lazyvim`, `llm-agents`, `nix-flatpak` and `strata`. Modules take them as `{ skwd-wall, ... }` and so on.
- `nh os switch .` (or `nixos-rebuild switch --flake .#oolong`) builds the entry matching the hostname.

```nix
{
  description = "NixOS Configuration";

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lazyvim.url = "github:pfassina/lazyvim-nix";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { self, nixpkgs, home-manager, lazyvim, llm-agents, ... }: {
    # oolong == work computer
    nixosConfigurations.oolong = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./systems/oolong
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit lazyvim llm-agents; };

          home-manager.users.isaac.imports = [
            ./users/isaac.nix
            ./bundles/home/common.nix
            ./bundles/home/desktop.nix
            ./bundles/home/development.nix
          ];
        }
      ];
    };
  };
}
```

When the laptop arrives, this block moves into `lib/mkHost` and the `home-manager.users.isaac` imports should move into each `systems/<name>/default.nix`, so each machine can pick its own home bundles.

## systems/

The only machine is `oolong`, the work desktop (AMD CPU, btrfs with `home` and `nix` subvolumes). Its folder holds the NixOS bundle picks plus everything the installer generated.

- `default.nix` imports the three NixOS bundles and sets hostname, boot loader, NetworkManager, timezone, locale, keyboard layout, the `isaac` user account and `system.stateVersion`.
- `hardware-configuration.nix` was generated by `nixos-generate-config`. Don't hand-edit it.
- There is no `hypr/monitors.lua`: `hyprland.lua` currently sets no monitors, so Hyprland auto-detects them.
- `system.stateVersion = "26.05"` is the release you installed with. Set once, never bump.

```nix
# systems/oolong/default.nix (trimmed)
{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../bundles/nixos/common.nix
    ../../bundles/nixos/desktop.nix
    ../../bundles/nixos/development.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "oolong";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";   # plus nine LC_* overrides
  services.xserver.xkb = { layout = "us"; variant = ""; };

  users.users.isaac = {
    isNormalUser = true;
    description = "isaac";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  system.stateVersion = "26.05";
}
```

The user's Home Manager imports are not here yet; they live in `flake.nix`. The htpc would import `common` and a future `media` bundle and skip `development`, so neovim, docker and the rest never land on it.

## bundles/

A bundle is a role a machine plays (common, desktop, development) expressed as a list of modules. NixOS bundles go in a system's `imports`; home bundles go in `home-manager.users.isaac.imports`.

| Bundle | Imports | Also sets |
| --- | --- | --- |
| `nixos/common.nix` | nothing | flakes + nix-command, `allowUnfree` |
| `nixos/desktop.nix` | `hyprland`, `localsend`, `fonts`, `keyring`, `greeter`, `flatpak`, `bluetooth`, `strata`, `skwd-wall` | — |
| `nixos/development.nix` | `docker`, `nix-ld`, `1password`, `llm-cache` | firewall TCP 3000 |
| `home/common.nix` | nothing | packages: fastfetch, ripgrep, bat, fd, lazygit, hyprlauncher |
| `home/desktop.nix` | `hyprland/hyprland.nix`, `terminal`, `browser`, `cursor`, `polkit`, `quickshell/quickshell.nix`, `xdg`, `screenshot` | packages: hyprlauncher, discord, playerctl |
| `home/development.nix` | `ssh`, `neovim`, `mise`, `git`, `gh`, `ai` | — |

- 1Password is in the development bundle, not desktop, because the SSH agent (`modules/home/ssh.nix`) depends on it.
- Mirror the names: `bundles/nixos/desktop.nix` and `bundles/home/desktop.nix` describe the same role from two sides.
- The rule is still imports only; the three bundles with real settings are listed under Drift.

```nix
# bundles/home/desktop.nix
{ ... }: {
  imports = [
    ../../modules/home/hyprland/hyprland.nix
    ../../modules/home/terminal.nix
    ../../modules/home/browser.nix
    ../../modules/home/polkit.nix
  ];
}
```

## modules/

One feature per file, written to work on any machine. A feature that needs a raw config file gets its own folder, and the file sits next to the `.nix` that loads it; there is no separate `dotfiles/` tree.

- `nixos/` is the system half (what pacman and `/etc` did on Arch); `home/` is the user half (what chezmoi and `~/.config` did).
- Hyprland is the only feature with both halves. 1Password and polkit are one-sided: 1Password is NixOS-only, polkit is enabled in `nixos/hyprland.nix` and its agent runs from `home/polkit.nix`.
- No hostnames, monitor names or hardware in here. If a value differs per machine, set it in `systems/`.
- Modules take flake inputs as named args: `neovim.nix` imports `lazyvim.homeManagerModules.default`; `ai.nix` installs claude-desktop, claude-code, codex and chatgpt from `llm-agents`.
- Modules that need a group add it themselves: `docker.nix` sets `users.users.isaac.extraGroups = [ "docker" ];` and NixOS merges the lists.

### Hyprland: where hyprland.lua lives

The config is `modules/home/hyprland/hyprland.lua`, beside `hyprland.nix`. Hyprland is installed by the NixOS module; Home Manager's `wayland.windowManager.hyprland` is enabled with `package = null` only to write the Lua config. That reverses the old advice not to enable the HM module.

```nix
# modules/nixos/hyprland.nix — system half
{ pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  hardware.graphics.enable = true;
  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.hyprland = {
      default = [ "hyprland" "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = "gtk";
    };
  };
}
```

```nix
# modules/home/hyprland/hyprland.nix — user half
{ ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;          # NixOS module already installs Hyprland
    portalPackage = null;    # and its portal
    systemd.enable = false;  # UWSM manages the session
    configType = "lua";
    extraConfig = builtins.readFile ./hyprland.lua;
  };
}
```

`hyprland.lua` binds Super+Return to ghostty, Super+Space to hyprlauncher (not fuzzel) and Super+W to the skwd-wall picker. It sets no monitors yet. When a second machine needs its own layout, keep the shared file here and set the per-machine part from `systems/<name>/`.

The file is read at build time with `builtins.readFile`, so edits need a rebuild.

### skwd-wall: wallpapers

`modules/nixos/skwd-wall.nix` imports upstream's NixOS module and sets `services.skwd-deck.enable = true`. That installs the suite (`skwd-wall-v2` picker, `skwd-walld` daemon, `skwd-paper` renderer, `skwd-lens` search plus its model) and a `skwd-walld` user service tied to `graphical-session.target`. It replaced awww and waypaper; don't run another wallpaper daemon beside it.

- The input is the `nix` branch, a release channel that upstream's CI rewrites on every release. It shares no history with the code branches; the source is the `v2` branch (MIT). Ignore `main`, which is the old v1 line.
- The packages are the prebuilt release binaries, patched with autoPatchelf, x86_64 only. `nix flake update skwd-wall` moves to the latest beta.
- Upstream's module reads `pkgs.system`, which prints a `'system' has been renamed` evaluation warning. It's harmless and not ours to fix.
- Steam Workshop uses steamcmd, which the module installs. The rest is runtime state, not Nix: run `steamcmd +login <user> +quit` once with the account that owns Wallpaper Engine, then set the method, username and Steam Web API key in skwd-wall under Settings > Sources > Steam Workshop and run `systemctl --user restart skwd-walld`.
- Items subscribed in the Steam client also show up, because skwd-wall reads Steam's Workshop folder. Wallpaper Engine scenes likely need Wallpaper Engine installed through Steam for its assets, which only latte has.
- Colour theming from wallpapers (Matugen into quickshell's `Theme.qml`) is not set up yet.

## users/

`users/isaac.nix` holds your Home Manager identity only: username, home directory, `home.stateVersion = "26.05"` and `programs.home-manager.enable`.

```nix
# users/isaac.nix
{ ... }: {
  home.username = "isaac";
  home.homeDirectory = "/home/isaac";
  home.stateVersion = "26.05";   # set once, never bump
  programs.home-manager.enable = true;
}
```

- Git name and email are not here; they sit in `modules/home/git.nix` under `programs.git.settings.user`, next to `init.defaultBranch` and `core.editor`.
- The NixOS account (groups, description) lives in `systems/oolong/default.nix`; there is no `modules/nixos/users.nix` yet.
- The shell is bash (`programs.bash.enable` in `mise.nix`), not zsh.

## Not built yet: lib/, docs/, dotfiles/

None of these folders exist in the repo today.

- **`dotfiles/` is dropped.** Raw config files now live inside their module folder (`modules/home/hyprland/hyprland.lua`). Follow that pattern for the next app that needs a native config file.
- **`lib/`** arrives with the second machine, so `flake.nix` doesn't repeat the `nixosSystem` block. Since the flake passes inputs by name today, `mkHost` should either keep doing that or switch every module to `inputs.lazyvim` / `inputs.llm-agents`.
- **`docs/`** would hold `BOOTSTRAP.md` (install steps for a new machine) and `HANDOFF.md` (where things stand, decisions made, what's next).

```nix
# lib/default.nix (planned)
{ inputs }: {
  mkHost = hostname: inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs hostname; };
    modules = [
      ../systems/${hostname}
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit hostname;
          inherit (inputs) lazyvim llm-agents;
        };
      }
    ];
  };
}
```

```nix
# flake.nix outputs, after lib/ exists
outputs = inputs:
  let lib = import ./lib { inherit inputs; };
  in {
    nixosConfigurations = {
      oolong = lib.mkHost "oolong";
      laptop = lib.mkHost "laptop";
      htpc   = lib.mkHost "htpc";
    };
  };
```

## Drift: where the repo breaks its own rules

None of these break anything; they are the spots to tidy when you next touch them.

| Where | What's off | Suggested home |
| --- | --- | --- |
| `flake.nix` | Home Manager user imports | `systems/oolong/default.nix` |
| `systems/oolong/default.nix` | User account, locale, timezone, boot loader | `modules/nixos/users.nix`, `locale.nix`, `boot.nix` via `bundles/nixos/common.nix` |
| `bundles/nixos/common.nix` | Nix settings instead of imports | `modules/nixos/nix.nix` |
| `bundles/home/common.nix` | Package list instead of imports | `modules/home/cli.nix` (hyprlauncher fits `hyprland/hyprland.nix`) |
| `bundles/nixos/development.nix` | Firewall port 3000 | `modules/nixos/dev-ports.nix`, or the host if only oolong needs it |
| `flake.nix` + `llm-cache.nix` | numtide cache declared twice | Intentional: flake for the first build, module for the system |

## Refactoring tips and gotchas

- **`git add` new files before building.** A flake in a git repo only sees tracked files; an untracked module fails with "path does not exist".
- **Build before you switch.** `nh os build .` or `nixos-rebuild build --flake .#oolong` catches errors without touching the running system; nh also shows a package diff.
- **Move one feature at a time** and rebuild after each move.
- **Count your `../`.** From `systems/oolong/` and `bundles/nixos/` the repo root is `../../`; from `flake.nix` it is `./`.
- **Same option set twice = conflict.** Use `lib.mkDefault` in the general place and a plain value (or `lib.mkForce`) in the specific one.
- **Lists and attrsets merge.** `extraGroups`, `home.packages` and `imports` from different files combine.
- **Rollback is always there.** Pick an older generation from the boot menu, or run `sudo nixos-rebuild switch --rollback`.
- **Decision test for where a line goes:** differs per machine → `systems/`; about you everywhere → `users/`; configures a feature → `modules/` (raw config file beside it); groups features → `bundles/`.
