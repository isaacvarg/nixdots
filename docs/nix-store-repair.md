# Repairing a Corrupted Nix Store

When a rebuild is interrupted (Ctrl+C, crash, hard reboot), some store files can end up half-written. Usually they're left empty.

## Symptoms

```
error: error parsing derivation '/nix/store/<hash>-<name>.drv': file is empty (possible filesystem corruption)
```

or, from `nix-store --verify`:

```
path '/nix/store/<hash>-<name>' was modified! expected hash '...', got '...'
error: cannot repair path '/nix/store/<hash>-<name>'
```

## 1. Find empty derivations

A `.drv` file is never empty when it's healthy. Other empty files, like `nameservers`, `extra-hosts` and `shellInit`, are normal, so leave them alone.

```bash
find /nix/store -maxdepth 1 -type f -empty -name '*.drv'
```

## 2. Delete them

```bash
sudo nix-store --delete /nix/store/<hash>-<name>.drv ...
```

If Nix says a path is "still alive", add `--ignore-liveness`.

## 3. Verify and repair the store

```bash
sudo nix-store --verify --check-contents --repair
```

Paths that can be downloaded from the binary cache are fixed automatically. A path built on your own machine can't be repaired this way and shows up as `cannot repair path`.

## 4. Handle paths that can't be repaired

Before deleting one, make sure it's safe:

```bash
P=/nix/store/<hash>-<name>
nix-store -q --roots $P                                  # must be empty
nix-store -q --referrers $P                              # what references it
nix-store -qR /run/current-system | grep <hash>          # must be empty
```

If it has no roots and isn't in the running system, delete it along with its referrers. Put the referrers first, because Nix won't delete a path that something still references:

```bash
sudo nix-store --delete <referrers...> $P
```

Then run step 3 again until it finishes clean.

## 5. Rebuild

```bash
sudo nixos-rebuild switch --flake ~/.nixdots
sudo nix-collect-garbage   # optional: clear leftovers
```

If the rebuild fails on another empty `.drv`, go back to step 2.

## Notes

- If the system won't boot properly, choose an earlier generation in the boot menu first. Then do the repair from there.
- Don't pass a `#host` that doesn't belong to the machine you're on. `--flake ~/.nixdots` with no `#host` uses the current hostname.
