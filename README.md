# Dev Container Features

[Dev Container Features](https://containers.dev/implementors/features/) for Meta's Muse Code CLI and the Helicon extension, published to GitHub Container Registry.

| Feature | Reference |
| --- | --- |
| [muse-code](#muse-code) | `ghcr.io/harjjotsinghh/devcontainer-features/muse-code:1` |

## muse-code

Installs Meta's Muse Code CLI (`muse`) for the container's remote user and recommends the Helicon extension in VS Code.

### Usage

Add the Feature to your `devcontainer.json`:

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/harjjotsinghh/devcontainer-features/muse-code:1": {}
    }
}
```

Then sign in once inside the container:

```bash
muse login
```

The Feature never signs in for you, so no credentials end up in the image.

### What it does

- Runs Meta's installer (`https://dev.meta.ai/install.sh`) with `HOME` set to the remote user's home, so the launcher lands in `~/.local/bin/muse` for `remoteUser` (or the container user if `remoteUser` is not set). Files are owned by that user.
- The launcher downloads the `muse` binary (about 330 MB) and checks for updates every hour. Set `MUSE_NO_AUTO_UPDATE=1` in `containerEnv` or `remoteEnv` to turn that off.
- Installs `bash`, `curl` and `ca-certificates` if they are missing. Works with apt (Debian, Ubuntu), apk (Alpine), dnf, microdnf and yum.
- Adds `/etc/profile.d/muse-code.sh` to put `~/.local/bin` on `PATH` for login shells, and links `/usr/local/bin/muse` to the launcher for everything else.
- Supports x86_64 and aarch64 Linux images.

### Options

This Feature has no options.

### The Helicon extension

The Feature adds `harjjotsinghh.helicon` to `customizations.vscode.extensions`. The Feature spec does not let an option turn customizations on or off, so the extension is always recommended. To skip it in VS Code, list it with a leading minus in your own `devcontainer.json`:

```jsonc
"customizations": {
    "vscode": {
        "extensions": ["-harjjotsinghh.helicon"]
    }
}
```

Helicon is an unofficial, open-source (MIT) GUI and VS Code / Cursor extension for Muse Code. It is not affiliated with or endorsed by Meta. If you run Muse Code on a remote machine, the [Muse Code over SSH guide](https://helicon.sh/guides/muse-code-over-ssh?utm_source=devcontainer&utm_medium=listing&utm_campaign=directory) covers the same setup outside a dev container.

## Development

The layout follows [devcontainers/feature-starter](https://github.com/devcontainers/feature-starter):

- `src/<id>/devcontainer-feature.json` and `src/<id>/install.sh` define each Feature.
- `test/<id>/` holds tests for the [devcontainer CLI](https://github.com/devcontainers/cli/blob/main/docs/features/test.md).
- `.github/workflows/release.yaml` publishes to GHCR with [devcontainers/action](https://github.com/devcontainers/action). Run it from the Actions tab.

Run the tests locally with Docker and the devcontainer CLI:

```bash
npm install -g @devcontainers/cli
devcontainer features test -f muse-code -i mcr.microsoft.com/devcontainers/base:ubuntu .
```

## License

[MIT](LICENSE). Muse Code itself is Meta's software and is covered by Meta's own terms.
