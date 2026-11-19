# Secrets (sops-nix)

Secrets live encrypted in `secrets/<host>.yaml`. Each file is encrypted to two age keys:

- **isaac**: my editing key. The private half lives only in 1Password (`op://Private/sops-age-key/password`).
- **the host**: `/var/lib/sops-nix/key.txt`, root-only, never leaves the machine. sops-nix decrypts with it at activation.

`.sops.yaml` holds only the public keys and decides which keys a file is encrypted to.

## Editing a secret

```bash
SOPS_AGE_KEY=$(op read "op://Private/sops-age-key/password") sops secrets/latte.yaml
```

## One-time setup

Run steps 1 and 2 with `nix shell nixpkgs#age nixpkgs#sops` if the tools aren't installed yet.

1. Personal key (only once, ever):

   ```bash
   op item create --category password --vault Private --title sops-age-key \
     "password=$(age-keygen 2>/dev/null | grep AGE-SECRET-KEY)"
   op read "op://Private/sops-age-key/password" | age-keygen -y   # public key
   ```

2. Host key (once per machine):

   ```bash
   sudo install -d -m 700 /var/lib/sops-nix
   sudo age-keygen -o /var/lib/sops-nix/key.txt
   sudo age-keygen -y /var/lib/sops-nix/key.txt                   # public key
   ```

   Back up the private half to 1Password, so a reinstall can reuse the key:

   ```bash
   op item create --category password --vault Private --title latte-sops-host-key \
     "password=$(sudo grep AGE-SECRET-KEY /var/lib/sops-nix/key.txt)"
   ```

3. Put both public keys in `.sops.yaml`, then create the file:

   ```bash
   SOPS_AGE_KEY=$(op read "op://Private/sops-age-key/password") sops secrets/latte.yaml
   ```

   ```yaml
   nas:
     username: ...
     password: ...
   ```

4. `git add secrets/latte.yaml` (flakes only see tracked files), then rebuild.

## After a reinstall

Restore the host key before the first rebuild. Nothing in the repo changes:

```bash
sudo install -d -m 700 /var/lib/sops-nix
op read "op://Private/latte-sops-host-key/password" | sudo tee /var/lib/sops-nix/key.txt > /dev/null
sudo chmod 600 /var/lib/sops-nix/key.txt
```

If the backup is gone too, make a new host key (step 2), replace its public key in `.sops.yaml`, then re-encrypt with your editing key and commit:

```bash
SOPS_AGE_KEY=$(op read "op://Private/sops-age-key/password") sops updatekeys secrets/latte.yaml
```

## Adding a host

Generate its host key (step 2), add it to `keys` in `.sops.yaml` with a new `creation_rules` entry for `secrets/<host>.yaml`, then import `sops-nix.nixosModules.sops` for that host in `flake.nix`, plus `modules/nixos/sops.nix`.
