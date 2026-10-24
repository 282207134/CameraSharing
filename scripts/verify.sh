#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter analyze
flutter test
if [[ $# -gt 0 ]]; then
  flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d "$1"
fi
