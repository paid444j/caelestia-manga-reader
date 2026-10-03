# Troubleshooting

## A reader panel does not open

Confirm the host configuration includes the reader flyout, focus handling, region mask (when used by that version), and launcher actions described in [INSTALL.md](../INSTALL.md). Check the Caelestia/Quickshell logs for QML import or component errors.

## A backend fails to start

Check that the corresponding script was copied to `~/.local/share/caelestia/readers/scripts/` and that its interpreter exists:

- Manga: `~/.local/share/caelestia/readers/venvs/manga/bin/python3`
- Novel: `~/.local/share/caelestia/readers/venvs/novel/bin/python3`

Install the dependencies into both environments with the package's `requirements.txt`. Run the script manually with its configured interpreter to see startup errors.

## The UI cannot reach a backend

Check the service logs and confirm the local API is listening on port 5150 (manga) or 5151 (novel). Another process using either port can prevent startup. These backends should remain bound to localhost.

## Catalog pages are empty or fail to load

The backends fetch data from third-party sites, which can change availability or page structure. Confirm network access, then inspect backend logs for provider or parsing errors. A site-side change may require updating its provider implementation.

## Keep personal data safe during updates

Reader libraries and downloaded content are in `~/.local/share/caelestia/readers/`, outside the package payload. Back up that data before manually changing or removing the installed reader data directory.
