# Caelestia Manga + Novel Readers

A portable add-on package containing the manga and light novel reader interfaces and their local Python backends for Caelestia Shell on Arch Linux.

This package includes QML and backend source. It excludes Python virtual environments, caches, and personal reading libraries. Installation integrates panel and launcher hooks into the target Caelestia version; see `INSTALL.md` and `OPENCODE_PROMPT.md`.

## Documentation

- [Installation guide](INSTALL.md)
- [Architecture and runtime layout](docs/ARCHITECTURE.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [OpenCode installation prompt](OPENCODE_PROMPT.md)

## Quick use with OpenCode

1. Extract this package, or upload the ZIP to a place OpenCode can access.
2. In the target Caelestia config/repository, give OpenCode the contents of `OPENCODE_PROMPT.md` and ask it to follow `INSTALL.md`.

The backend uses Python 3 and `curl_cffi`; the installer should create separate virtual environments for manga and novel under `~/.local/share/caelestia/readers/venvs/` and install `requirements.txt` in both. No system-wide Python packages are needed.

## Source and license

The reader UI was adapted from [dhrruvsharma/shell](https://github.com/dhrruvsharma/shell), upstream commit `4704e91aa26342243330175c511475c26140d52d`, under GPL-3.0-or-later. See `LICENSE-GPL-3.0.txt`. The package also contains local changes and backend implementations. Preserve attribution and the license when redistributing.
