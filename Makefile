APP_NAME    := Tab
APP         := build/$(APP_NAME).app
INSTALL_DIR := /Applications
INSTALLED   := $(INSTALL_DIR)/$(APP_NAME).app
CLI         := $(INSTALLED)/Contents/MacOS/tab
CERT_NAME   := Tab Local Code Signing
TOOLS       := cargo rustup pnpm protoc cargo-tauri python3.11

# Find tools that make setup just installed, before the shell config is reloaded
PYENV_ROOT  ?= $(HOME)/.pyenv
export PATH := $(HOME)/.cargo/bin:$(PYENV_ROOT)/shims:$(HOME)/.local/share/mise/shims:$(PATH)

# make build FAST=1 skips tests and lints; ARGS passes anything else to build-scripts/main.py
ARGS ?=
ifdef FAST
ARGS += --skip-tests --skip-lints
endif

.DEFAULT_GOAL := help

.PHONY: help setup cert check build install run update test lint clean distclean uninstall

help: ## Show this help
	@echo "Tab targets:"
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-10s %s\n", $$1, $$2}'
	@echo
	@echo "First time:     make setup cert install run"
	@echo "Faster rebuild: make install FAST=1"

setup: ## Install missing prerequisites (Rust, protoc, Python 3.11, Node, Tauri CLI); safe to re-run
	scripts/setup.sh
	@$(MAKE) --no-print-directory check

cert: ## Create the local signing certificate (keeps Accessibility across rebuilds)
	scripts/create-signing-cert.sh

check: ## Check prerequisites, signing certificate and conflicting apps
	@ok=1; for tool in $(TOOLS); do \
		if command -v $$tool >/dev/null 2>&1; then echo "  ok       $$tool"; \
		else echo "  missing  $$tool"; ok=0; fi; \
	done; \
	if security find-identity -p codesigning 2>/dev/null | grep -qF '"$(CERT_NAME)"'; then \
		echo "  ok       signing certificate"; \
	else echo "  missing  signing certificate (optional: make cert)"; fi; \
	for app in "Kiro CLI" "Amazon Q" Fig; do \
		if [ -d "$(INSTALL_DIR)/$$app.app" ]; then \
			echo "  conflict $(INSTALL_DIR)/$$app.app (uninstall it first)"; ok=0; fi; \
	done; \
	[ $$ok = 1 ] || { echo; echo "Fix the above (make setup installs missing tools)"; exit 1; }

build: check ## Build and sign build/Tab.app (FAST=1 skips tests and lints)
	scripts/build-local.sh $(ARGS)

install: build ## Build, then install into /Applications (quits a running Tab first)
	scripts/install-local.sh --no-open
	@echo "Next: make run"

run: ## Launch the installed app
	@[ -d "$(INSTALLED)" ] || { echo "$(INSTALLED) not found, run: make install" >&2; exit 1; }
	open "$(INSTALLED)"

update: ## Pull the latest changes, reinstall and relaunch
	git pull --ff-only
	$(MAKE) install run

test: ## Run Rust and TypeScript tests
	cargo test --workspace
	pnpm install && pnpm test --run

lint: ## Run clippy and the TypeScript linters
	cargo clippy --workspace --all-targets -- -D warnings
	pnpm lint

clean: ## Remove build/ (keeps the Cargo cache in target/)
	rm -rf build

distclean: clean ## Also remove target/, .venv and node_modules
	rm -rf target .venv node_modules

uninstall: ## Remove the app, shell integrations and Tab data
	@[ -x "$(CLI)" ] || { echo "$(INSTALLED) is not installed" >&2; exit 1; }
	"$(CLI)" uninstall
	@echo "Optional: security delete-identity -c \"$(CERT_NAME)\""
