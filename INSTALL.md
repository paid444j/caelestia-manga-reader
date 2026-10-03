# Installation guide for Caelestia on Arch Linux

Install into the user's Caelestia QuickShell config. Typical config root: `~/.config/quickshell/caelestia/`. Do not overwrite unrelated files. Back up destination files before replacing them and keep backups for rollback.

## 1. Copy package files

Copy the directory tree under `payload/quickshell/` into `~/.config/quickshell/caelestia/`, preserving paths. For example, `payload/quickshell/modules/manga/MangaReader.qml` goes to `~/.config/quickshell/caelestia/modules/manga/MangaReader.qml`.

Copy `payload/reader-backends/manga_server.py` to `~/.local/share/caelestia/readers/scripts/manga_server.py` and the full `payload/reader-backends/novel_server/` directory to `~/.local/share/caelestia/readers/scripts/novel_server/`. Create parent directories as needed. Do not copy library JSON files; each install starts with an empty library.

## 2. Set up backend Python environments

Use `python3 -m venv` to create:

- `~/.local/share/caelestia/readers/venvs/manga`
- `~/.local/share/caelestia/readers/venvs/novel`

For each venv, run its `bin/python -m pip install -r requirements.txt` using this package's `requirements.txt`. Keep venvs on the target machine; never ship or reuse venvs from another system. The QML services launch these exact interpreter and script paths.

## 3. Integrate the shell UI

Adapt to the target version's structure; inspect files before editing. Required hooks:

- In `modules/drawers/Panels.qml`, import `qs.modules.readers as Readers`, expose a `readers` alias, and instantiate `Readers.Flyout` with `screenState: root.screenState` and `bar: root.bar`, anchored top and bottom. Follow the current panel pattern.
- In `modules/drawers/ContentWindow.qml`, include `panels.readers.activeReader !== ""` in the drawer's keyboard-focus and focus-grab conditions. Close the reader panel when focus is cleared.
- In `modules/drawers/Regions.qml`, add the reader panel as a subtractive `R { panel: root.panels.readers }` region if this file uses the region mask pattern.
- In `modules/launcher/services/Actions.qml`, add Manga and Novel launcher actions that call `qs -c caelestia ipc call readers openManga` and `... openNovel` (or the target config's equivalent instance name).

The `Readers.qml` service supplies the `readers` IPC target and is included in the payload. Ensure Caelestia's singleton QML module discovery loads it automatically, as it does other files under `services/`.

## 4. Check and restart

Run the target project's existing QML/config validation if available, then restart/reload Caelestia. From the launcher, open Manga or Novel. Backends listen only on localhost ports 5150 and 5151. Reading lists and manga downloads stay in `~/.local/share/caelestia/readers/`.

## Notes

- This is a source add-on for Caelestia Shell, not a standalone desktop application. The host still needs Caelestia's dependencies, including Quickshell and its configured Qt modules.
- Manga and novel data are fetched from their configured upstream websites; network access is required and those sites may change independently.
- If the host's Caelestia layout differs, port the integrations to that version instead of applying textual patches blindly.
