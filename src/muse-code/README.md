
# Muse Code CLI (muse-code)

Installs Meta's Muse Code CLI (muse) for the remote user and recommends the Helicon extension, an unofficial Muse Code GUI for VS Code.

## Example Usage

```json
"features": {
    "ghcr.io/HarjjotSinghh/devcontainer-features/muse-code:1": {}
}
```



## Customizations

### VS Code Extensions

- `harjjotsinghh.helicon`

## Signing in

The Feature does not sign in for you. Run this once inside the container:

```bash
muse login
```

## What it installs

- Meta's Muse Code launcher at `~/.local/bin/muse` for the remote user, installed with Meta's script from `https://dev.meta.ai/install.sh`. The launcher downloads the `muse` binary (about 330 MB) and checks for updates hourly.
- `bash`, `curl` and `ca-certificates` if they are missing (apt, apk, dnf, microdnf or yum).
- `/etc/profile.d/muse-code.sh`, which puts `~/.local/bin` on `PATH` for login shells, and a `/usr/local/bin/muse` symlink for everything else.

Supported: x86_64 and aarch64 Linux images, including Debian, Ubuntu and Alpine.

## The Helicon extension

The Feature adds `harjjotsinghh.helicon` to the VS Code extensions list. The Feature spec does not let an option switch customizations on or off, so the extension is always recommended. To skip it in VS Code, add `"-harjjotsinghh.helicon"` to `customizations.vscode.extensions` in your `devcontainer.json`.

Helicon is an unofficial, open-source (MIT) GUI and extension for Muse Code. It is not affiliated with or endorsed by Meta.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/HarjjotSinghh/devcontainer-features/blob/main/src/muse-code/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
