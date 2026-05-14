# QGroundControl Development Commands
# Install (requires just >=1.30 for home_directory()):
#   python tools/setup/install_python.py dev   (recommended; pulls rust-just into .venv)
#   brew install just / cargo install just / pipx install rust-just
# `apt install just` on Ubuntu ships 1.21 which is too old.

# Configuration from build-config.json
qt_version := `python3 ./tools/setup/read_config.py --get qt_version 2>/dev/null || echo "6.10.1"`
qt_dir := env_var_or_default("QT_DIR", home_directory() / "Qt" / qt_version / "gcc_64")
build_type := env_var_or_default("BUILD_TYPE", "Debug")
build_dir := "build"

# Pin CMake's Python to the workspace .venv when present so CMake-invoked
# generators (settings_qml/config_qml use jinja2) see the deps they need.
# Empty when no .venv → CMake falls back to system python.
venv_python := `if [ -x .venv/bin/python ]; then echo "$PWD/.venv/bin/python"; elif [ -x .venv/Scripts/python.exe ]; then echo "$PWD/.venv/Scripts/python.exe"; else echo ""; fi`

# Default: show available commands
default:
    @just --list --unsorted

# ─────────────────────────────────────────────────────────────────────────────
# Setup
# ─────────────────────────────────────────────────────────────────────────────

# Install system dependencies (Debian/Ubuntu)
deps:
    @echo "Installing dependencies (requires sudo)..."
    python3 ./tools/setup/install_dependencies --platform debian

# Initialize git submodules
submodules:
    git submodule update --init --recursive

# ─────────────────────────────────────────────────────────────────────────────
# Build
# ─────────────────────────────────────────────────────────────────────────────

# Configure CMake build
configure: submodules
    {{qt_dir}}/bin/qt-cmake -B {{build_dir}} -G Ninja \
        -DCMAKE_BUILD_TYPE={{build_type}} \
        -DQGC_BUILD_TESTING=ON \
        {{ if venv_python != "" { "-DPython3_EXECUTABLE=" + venv_python } else { "" } }}

# Build the project
build:
    cmake --build {{build_dir}} --config {{build_type}} --parallel

# Configure and build Release
release:
    {{qt_dir}}/bin/qt-cmake -B {{build_dir}} -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DQGC_BUILD_TESTING=OFF \
        {{ if venv_python != "" { "-DPython3_EXECUTABLE=" + venv_python } else { "" } }}
    cmake --build {{build_dir}} --config Release --parallel

# Clean build directory (forwards to tools/clean.py; pass --cache, --all, --dry-run)
clean *ARGS:
    ./tools/clean.py {{ARGS}}

# Clean, configure, and build
rebuild: clean configure build

# Full setup: deps, submodules, configure, build
setup: deps submodules configure build

# ─────────────────────────────────────────────────────────────────────────────
# Quality
# ─────────────────────────────────────────────────────────────────────────────

# Run unit tests (matches CI label filters; override with `LABELS=... EXCLUDE=... just test`)
test labels=env_var_or_default("LABELS", "Unit|Integration") exclude=env_var_or_default("EXCLUDE", "Flaky|Network"):
    cd {{build_dir}} && ctest --output-on-failure -L "{{labels}}" -LE "{{exclude}}"

# Run pre-commit checks
lint:
    pre-commit run --all-files

# Check code formatting (no changes)
format:
    python3 ./tools/analyze.py --tool clang-format

# Format code (apply fixes)
format-fix:
    python3 ./tools/analyze.py --tool clang-format --fix

# Run static analysis
analyze:
    python3 ./tools/analyze.py

# Generate coverage report
coverage:
    python3 ./tools/coverage.py

# Run lint + test
check: lint test

# ─────────────────────────────────────────────────────────────────────────────
# Run & Deploy
# ─────────────────────────────────────────────────────────────────────────────

# Launch QGroundControl
run:
    ./{{build_dir}}/{{build_type}}/QGroundControl

# Build documentation
docs:
    npm run docs:build

# Build using Docker (Ubuntu)
docker:
    ./deploy/docker/run-docker-ubuntu.sh

# ─────────────────────────────────────────────────────────────────────────────
# Utilities
# ─────────────────────────────────────────────────────────────────────────────

# Show build configuration
info:
    @echo "Qt version:  {{qt_version}}"
    @echo "Qt dir:      {{qt_dir}}"
    @echo "Build type:  {{build_type}}"
    @echo "Build dir:   {{build_dir}}"

# Check dependency versions
check-deps:
    python3 ./tools/check_deps.py

# Clean build, caches, and generated files
distclean:
    ./tools/clean.py --all
    rm -rf node_modules

# ─────────────────────────────────────────────────────────────────────────────
# Android
# ─────────────────────────────────────────────────────────────────────────────

android_build_dir := env_var_or_default("ANDROID_BUILD_DIR", "build_android")
android_keystore  := env_var_or_default("QT_ANDROID_KEYSTORE_PATH", "/tmp/qgc-debug.keystore")
android_alias     := env_var_or_default("QT_ANDROID_KEYSTORE_ALIAS", "androiddebugkey")
android_store_pass := env_var_or_default("QT_ANDROID_KEYSTORE_STORE_PASS", "android")
android_key_pass  := env_var_or_default("QT_ANDROID_KEYSTORE_KEY_PASS", "android")

# Create a local debug keystore for APK signing (one-time setup)
android-keystore:
    @if [ -f "{{android_keystore}}" ]; then \
        echo "Keystore already exists at {{android_keystore}}"; \
    else \
        keytool -genkey -v \
          -keystore "{{android_keystore}}" \
          -storepass "{{android_store_pass}}" \
          -alias "{{android_alias}}" \
          -keypass "{{android_key_pass}}" \
          -keyalg RSA -keysize 2048 -validity 10000 \
          -dname "CN=Android Debug,O=Android,C=US" && \
        echo "Debug keystore created at {{android_keystore}}"; \
    fi

# Sign the unsigned APK produced by the Android build
android-sign: android-keystore
    #!/usr/bin/env bash
    set -euo pipefail
    UNSIGNED=$(find "{{android_build_dir}}" -name "*-unsigned.apk" | head -1)
    if [ -z "$UNSIGNED" ]; then
        echo "No unsigned APK found under {{android_build_dir}}. Run the Android build first." >&2
        exit 1
    fi
    SIGNED="${UNSIGNED/-unsigned/-signed}"
    cp "$UNSIGNED" "$SIGNED"
    jarsigner -sigalg SHA256withRSA -digestalg SHA-256 \
        -keystore "{{android_keystore}}" \
        -storepass "{{android_store_pass}}" \
        -keypass "{{android_key_pass}}" \
        "$SIGNED" "{{android_alias}}"
    jarsigner -verify "$SIGNED" | grep -E "jar verified|ERROR"
    echo ""
    echo "Signed APK: $SIGNED"
    echo ""
    echo "Install with:  adb install \"$SIGNED\""

# Install signed APK onto a connected device via adb
android-install: android-sign
    #!/usr/bin/env bash
    set -euo pipefail
    SIGNED=$(find "{{android_build_dir}}" -name "*-signed.apk" | head -1)
    if [ -z "$SIGNED" ]; then
        echo "No signed APK found. Run 'just android-sign' first." >&2
        exit 1
    fi
    adb install -r "$SIGNED"
