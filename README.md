# Tab

IDE-style autocomplete for your existing macOS terminal, fully offline.

> **This is a personal fork.** [glrodasz/tabulador](https://github.com/glrodasz/tabulador) is
> Guillermo Rodas's own version of [kayluhb/tab](https://github.com/kayluhb/tab) by Caleb Brown.
> It adds a Makefile-based setup and other developer-experience changes, and it no longer syncs
> with upstream. Credit for Tab goes to Caleb Brown, and for the original autocomplete to AWS and
> the Fig team. The licenses and [NOTICE](NOTICE) are unchanged.

Tab itself is a standalone fork of
[aws/amazon-q-developer-cli-autocomplete](https://github.com/aws/amazon-q-developer-cli-autocomplete)
(formerly Fig). It keeps only the graphical terminal autocomplete, which Kiro CLI is
[sunsetting](https://github.com/kirodotdev/Kiro/issues/11728), and removes everything that
needs an AWS backend:

- No login, telemetry, update checks, chat, translate or AI inline completions.
  All AWS service clients have been removed, and Tab makes no network requests.
- Completion specs are built from [withfig/autocomplete](https://github.com/withfig/autocomplete)
  (MIT) at a pinned commit and bundled into the app, together with their icons.
- macOS only. You build it yourself and sign it with a local certificate, so no Apple Developer
  account is needed.

Tab is not affiliated with or endorsed by Amazon Web Services.

## Requirements

- macOS with [Homebrew](https://brew.sh). Everything else is installed by `make setup`:
  - Xcode command line tools
  - rustup, the pinned toolchain from `rust-toolchain.toml` (Rust 1.88) and `nightly-2025-11-01`
    for formatting
  - Node 22 and Python 3.11, pinned in `.nvmrc` and `.python-version`. They come from nvm and
    pyenv when you have them, otherwise from [mise](https://mise.jdx.dev). Node builds the
    autocomplete and dashboard UIs and the completion specs
  - pnpm and protobuf
  - The Tauri 1 CLI, built with Rust 1.79

  `make setup` skips anything already installed, so it is safe to re-run. `make check` shows
  what is still missing.

Uninstall or disable Kiro CLI, Amazon Q or Fig first. Their shell hooks conflict with Tab's.

## Quick start

On a Mac with [Homebrew](https://brew.sh):

```sh
make setup     # 1. install missing prerequisites (safe to re-run)
make check     # 2. confirm everything is in place
make cert      # 3. once per Mac: signing certificate, keeps Accessibility across rebuilds
make install   # 4. build, sign and install Tab to /Applications
make run       # 5. launch Tab
```

`make setup` adds Cargo and, if it is used, mise to your shell config (`~/.zshrc`,
`~/.bashrc` or `config.fish`). `make install` also runs the tests and lints, which takes a while.
`make install FAST=1` skips them.

On first launch, onboarding installs the shell integrations (a pre and post block in
`~/.zshrc`, `~/.bashrc` and so on) and asks for **Accessibility** permission in
System Settings → Privacy & Security → Accessibility. Then open a new terminal window.

### Make targets

Run `make` to list them all.

| Target | What it does |
| --- | --- |
| `make setup` | Install missing prerequisites |
| `make check` | List missing tools, the signing certificate and conflicting apps |
| `make cert` | Create the local signing certificate |
| `make build` | Build and sign `build/Tab.app` |
| `make install` | Build, quit a running Tab and install to `/Applications` |
| `make run` | Launch the installed app |
| `make update` | `git pull`, then install and relaunch |
| `make test` / `make lint` | Rust and TypeScript tests / clippy and linters |
| `make clean` / `make distclean` | Remove `build/` / also `target/`, `.venv` and `node_modules` |
| `make uninstall` | Remove the app, shell integrations and Tab's data |

`FAST=1` skips tests and lints on `build` and `install`. `ARGS` passes anything else to the
build script, for example `make build ARGS="--variant minimal"`. The `scripts/` that the
targets call also work on their own.

### Updating

```sh
make update    # git pull, then make install run
```

Use `make install` rather than copying the app over the installed one: macOS kills a
signed binary that is modified in place, and the script also refreshes the `tabterm` copies
in `~/.local/bin`.

Accessibility permission is tied to the app's signature. With the local certificate it
carries over between rebuilds. Without it, the app is ad-hoc signed and you have to remove
and re-add Tab under Accessibility after each rebuild.

## Usage

Type a command and Tab suggests subcommands, options and arguments. Default keys:

| Key | Action |
| --- | --- |
| ↑ / ↓ | Move through suggestions |
| Enter | Insert the selected suggestion |
| Tab | Insert the common prefix |
| Esc | Hide the popup |
| Ctrl+R | Toggle history mode |

Change them in `tab dashboard` under Keybindings.

```sh
tab doctor      # check the installation
tab settings    # view or change settings
tab dashboard   # open the settings dashboard
tab --help-all  # all commands
```

### Custom specs

Specs in `~/Library/Application Support/tab/autocomplete/specs/` override the bundled ones.
Use the same layout as the withfig build output: an `index.json` listing the specs, plus
`<name>.js` files. To bundle newer withfig specs, change `SPECS_COMMIT` in
`build-scripts/build.py` and rebuild.

withfig/autocomplete is no longer maintained, so newer or missing specs, such as `claude` for
Claude Code, live in `specs/` as TypeScript, laid out like withfig's `src/`. The build copies
them over the withfig sources before compiling, so `specs/gh.ts` replaces withfig's `gh` spec.
Some are generated from a tool's help output by scripts in `build-scripts/specs/`; each
generated spec's first line says how.

### Troubleshooting

- Run `tab doctor` in a new terminal window. It must run inside a Tab session, so it reports
  that `tabterm` is not running in terminals opened before installing.
- No popup: check that Tab is enabled under Accessibility. If it is listed but autocomplete
  still doesn't work, remove it with **–** and add `/Applications/Tab.app` again.
- Logs are in `$TMPDIR/tablog` (for example `tab_desktop.log`).

## Uninstall

```sh
make uninstall                                         # runs tab uninstall
security delete-identity -c "Tab Local Code Signing"   # optional: remove the signing certificate
```

`tab uninstall` removes the app, the shell integrations, the input method and Tab's data in
`~/Library/Application Support/tab`.

## Development

```sh
make test   # cargo test --workspace, pnpm test --run
make lint   # cargo clippy, pnpm lint
```

Pre-commit hooks run rustfmt, clippy, prettier, ruff and typos on staged files. Three Rust
tests need `fish` and `nu`, which `make setup` installs.

## Project layout

- [`crates/tab_cli`](crates/tab_cli/): the `tab` CLI
- [`crates/tabterm`](crates/tabterm/): `tabterm`, the pseudoterminal that reads the terminal
  edit buffer
- [`crates/tab_desktop`](crates/tab_desktop/): the desktop app
  ([`tao`](https://docs.rs/tao/latest/tao/)/[`wry`](https://docs.rs/wry/latest/wry/)) that
  shows the autocomplete window
- [`crates/tab_input_method`](crates/tab_input_method/): the input method that gets the cursor
  position
- [`crates/tab_integrations`](crates/tab_integrations/): shell, SSH, input method and VS Code
  integrations
- [`packages/autocomplete-app`](packages/autocomplete-app/): the autocomplete React app
- [`packages/dashboard-app`](packages/dashboard-app/): the settings dashboard
- [`build-scripts/`](build-scripts/): Python build scripts
- [`proto/`](proto/): protocol buffer messages for IPC
- [`tests/`](tests/): integration tests

## Licensing

Dual licensed under [MIT](LICENSE.MIT) and [Apache 2.0](LICENSE.APACHE), the same as
the original project. The changes from upstream are in this repository's git history.

"Amazon Web Services", "Amazon Q" and related marks are trademarks of AWS.
