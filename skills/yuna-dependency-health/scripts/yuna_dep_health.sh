#!/usr/bin/env bash
set -u

ROOT="${1:-.}"
cd "$ROOT" || exit 1

if [ -f pubspec.yaml ]; then
  echo "=== Flutter/Dart ==="
  if command -v flutter >/dev/null 2>&1; then
    flutter pub outdated || true
  elif command -v dart >/dev/null 2>&1; then
    dart pub outdated || true
  else
    echo "[skipped] flutter/dart not installed"
  fi
else
  echo "No pubspec.yaml found."
  exit 2
fi
