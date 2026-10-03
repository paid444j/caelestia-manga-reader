# How the package is organized

This project adds manga and light novel reading panels to an existing Caelestia Shell setup. It is an add-on source package, not a standalone application.

## Main parts

- `payload/quickshell/modules/` contains the reader panels, browse and library views, detail pages, and reading views.
- `payload/quickshell/services/` contains the QML services that manage reader state and communicate with the local backends.
- `payload/reader-backends/manga_server.py` provides the manga HTTP API.
- `payload/reader-backends/novel_server/` provides the novel HTTP API and provider implementation.
- `requirements.txt` lists the Python dependency used by both backends.

The QML services start their backend processes locally. The manga and novel services use ports 5150 and 5151 respectively. Both are intended to listen only on the local machine.

## Runtime data

Installed scripts and Python environments live under `~/.local/share/caelestia/readers/`. Reading lists and downloaded manga are stored under that data directory as well. Runtime data and virtual environments are deliberately excluded from this source package; create environments on the target machine as described in [the installation guide](../INSTALL.md).

## UI integration

The host Caelestia configuration owns the panel, keyboard focus, region mask, and launcher wiring. Those integration points can vary between Caelestia versions, so use the steps in [the installation guide](../INSTALL.md) as a checklist and adapt them after inspecting the target configuration.
