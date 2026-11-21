# Setting up an HTPC

How to set up a TV computer from a blank disk. It boots straight into Plasma Bigscreen with no login, and has Steam, VacuumTube, Netflix, Spotify and Jellyfin. matcha was the first one built this way.

The steps use `<host>` for the new machine's name and `<host-ip>` for its address on the network. Every command says where it runs, on the HTPC or on latte.

## What the config does

- `bundles/nixos/media.nix` brings in Plasma Bigscreen, SDDM, the apps, LocalSend, fonts and flatpak.
- `modules/nixos/bigscreen.nix` turns off Plasma's screen lock after idle and on wake.
- `modules/nixos/netflix.nix` adds Netflix as an app. It's Chromium with Widevine opening netflix.com full screen. Netflix limits Chromium on Linux to 720p.
- `modules/nixos/media-apps.nix` opens the Spotify Connect ports, so phones can cast to the TV.
- `modules/nixos/openssh.nix` allows SSH with keys only. The `nixos#latte` key from 1Password can log in.
- The user's password comes from `secrets/<host>.yaml` through sops. It's only for `sudo`, because autologin skips it.
- `users.mutableUsers = false` in the system file makes sure that sops password applies. The installer creates the user with its own password. With mutable users, NixOS keeps an existing password and ignores `hashedPasswordFile`. Root stays locked.

## 1. Add the host to the repo (on latte)

Skip this for matcha, which already exists.

1. Copy matcha's system folder, leaving out its hardware config:
   ```bash
   mkdir systems/<host> && cp systems/matcha/default.nix systems/<host>/
   ```
2. In `systems/<host>/default.nix`, set `networking.hostName` to `<host>`. Change `../../secrets/matcha.yaml` to `../../secrets/<host>.yaml`.
3. In `flake.nix`, copy the `nixosConfigurations.matcha` block, rename it to `<host>`, and point it at `./systems/<host>`.

Don't commit yet. The host won't evaluate until it has a hardware config and a secret file, which come in steps 4 and 5.

## 2. Install NixOS (on the HTPC)

Use the graphical installer and create user `isaac`. The password you pick only matters until the first switch to the flake, when the sops password replaces it.

## 3. Connect to wifi and turn on SSH (on the HTPC)

NetworkManager runs on a fresh install. If a desktop shows, click the network icon in the panel. In a terminal, use `nmtui`. Choose "Activate a connection", then your network, then enter the password.

To connect with one command instead:

```bash
nmcli device wifi list
```

```bash
nmcli device wifi connect "YourNetworkName" password "your-wifi-password"
```

Check it worked:

```bash
ping -c 3 github.com
```

The connection survives the switch to the flake. The config also uses NetworkManager, which keeps saved networks in `/etc/NetworkManager/system-connections`, and a rebuild doesn't touch that folder.

If `nmcli device` lists no wifi device, the card probably needs firmware that NixOS doesn't load by default. Add `hardware.enableRedistributableFirmware = true;` to the installer's config, or use a cable for now.

Turn on SSH so the rest can be done from latte:

```bash
sudo nano /etc/nixos/configuration.nix
```

Add `services.openssh.enable = true;` above the last `}`, then rebuild and find the address:

```bash
sudo nixos-rebuild switch
```

```bash
ip -4 addr
```

## 4. Make the host key and copy the hardware config

SSH in from latte. The installer's SSH accepts the password for now.

```bash
ssh isaac@<host-ip>
```

On the HTPC, open a shell with git and age. A fresh install has neither.

```bash
nix-shell -p git age
```

The repo is public, so it clones over HTTPS without keys.

```bash
git clone https://github.com/isaacvarg/nixdots.git ~/.nixdots
```

```bash
sudo install -d -m 700 /var/lib/sops-nix && sudo age-keygen -o /var/lib/sops-nix/key.txt
```

```bash
sudo age-keygen -y /var/lib/sops-nix/key.txt
```

Copy the `age1…` public key it prints, then `exit` back to latte. On latte, copy the hardware config into the repo:

```bash
scp isaac@<host-ip>:/etc/nixos/hardware-configuration.nix ~/.nixdots/systems/<host>/
```

## 5. Set up sops (on latte)

1. Add the host's public key under `keys` in `.sops.yaml`, and add a rule for its file to the existing `creation_rules` list. Don't start a second `creation_rules:` block. YAML allows each key once, and sops fails with `mapping key "creation_rules" already defined`.
   ```yaml
   keys:
     - &isaac age1nqkq8...
     - &latte age1jnu4...
     - &matcha age1zs83...
     - &<host> age1<new public key>

   creation_rules:
     - path_regex: ^secrets/latte\.yaml$
       # ...existing rules stay as they are

     - path_regex: ^secrets/<host>\.yaml$
       key_groups:
         - age:
             - *isaac
             - *<host>
   ```
2. Make a password hash. You'll type this password for `sudo`.
   ```bash
   nix-shell -p mkpasswd --run 'mkpasswd -m yescrypt'
   ```
3. Create the secret file:
   ```bash
   SOPS_AGE_KEY=$(op read "op://Private/sops-age-key/password") sops secrets/<host>.yaml
   ```
   Put the hash in it:
   ```yaml
   isaac:
     hashed-password: $y$j9T$...
   ```
4. Back up the host's private key to 1Password, so a reinstall can reuse it. Run the `grep` on the HTPC if ssh can't ask for the sudo password here.
   ```bash
   op item create --category password --vault Private --title <host>-sops-host-key "password=$(ssh isaac@<host-ip> sudo grep AGE-SECRET-KEY /var/lib/sops-nix/key.txt)"
   ```

## 6. Check and commit (on latte)

Before committing, make sure no secret is in plain text. The value under `hashed-password` in `secrets/<host>.yaml` should start with `ENC[`. `.sops.yaml` should hold only `age1…` public keys. This search should match only the examples in `docs/secrets.md`:

```bash
grep -rIl "AGE-SECRET-KEY\|BEGIN OPENSSH PRIVATE" --exclude-dir=.git .
```

Evaluate the host. The `path:` prefix includes files git doesn't track yet.

```bash
nix eval --raw "path:$PWD#nixosConfigurations.<host>.config.system.build.toplevel.drvPath"
```

Then add the new files, commit and push. Flakes ignore untracked files, so a forgotten `git add` shows up later as "does not exist in Git repository".

## 7. Switch to the flake (on the HTPC)

```bash
ssh isaac@<host-ip>
```

```bash
cd ~/.nixdots && nix-shell -p git --run 'git pull'
```

Flakes aren't on yet, so pass the flag this one time:

```bash
sudo nixos-rebuild boot --flake .#<host> --option experimental-features 'nix-command flakes'
```

```bash
sudo reboot
```

Use `boot` and a reboot rather than `switch`. Switching from the installer's desktop to Bigscreen while it runs can leave the display in a bad state.

After the reboot:

- The TV should start in Bigscreen with no login screen.
- `ssh isaac@<host>` from latte should log in with the 1Password key, without asking for a password.
- `sudo` should take the password from step 5. If it doesn't, sops didn't decrypt the secret. Boot the previous generation from the boot menu and check `journalctl -b -1 | grep sops`. The usual cause is a host key that doesn't match the one in `.sops.yaml`.

## 8. Sign in to the apps

Do this once on the TV:

- Steam. Sign in, then turn on "Start Steam in Big Picture Mode" in its settings.
- Netflix, Spotify and VacuumTube. Sign in to each.
- Jellyfin. Enter the server address and sign in.

## Updating later

Git is installed after the first switch, through `bundles/nixos/common.nix`.

```bash
cd ~/.nixdots && git pull && sudo nixos-rebuild switch --flake .
```

## After a reinstall

Restore the host key before the first rebuild, as described in `docs/secrets.md`. Then follow steps 2, 3 and 7. The repo doesn't change unless the disks did, in which case copy the new hardware config as in step 4.
