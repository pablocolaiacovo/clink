#!/usr/bin/env bash
# Lints, then builds and tests the iPhone and Watch apps on the newest available simulators.
# Usage: scripts/test.sh [lint|ios|watch|all]   (default: all)
set -euo pipefail
cd "$(dirname "$0")/.."

DERIVED_DATA="build/DerivedData"

# Prints the UDID of an available simulator on the newest runtime for a platform.
# $1: runtime platform (iOS, watchOS)  $2: device name prefix (iPhone, Apple Watch)
simulator_id() {
    xcrun simctl list devices available -j | jq -r --arg platform "$1" --arg device "$2" '
        .devices | to_entries
        | map(select(.key | test("SimRuntime\\." + $platform + "-")))
        | sort_by(.key | capture("-(?<v>[0-9-]+)$").v | split("-") | map(tonumber))
        | reverse | map(.value[] | select(.name | startswith($device))) | first | .udid // empty'
}

lint() {
    echo "==> Lint"
    xcrun swift-format lint --strict --recursive Clink "Clink Watch App" ClinkTests ClinkUITests "Clink Watch AppTests"
}

test_scheme() {
    local scheme="$1" platform="$2" device="$3" id
    id="$(simulator_id "$platform" "$device")"
    if [[ -z "$id" ]]; then
        echo "No $device simulator found for $platform" >&2
        exit 1
    fi
    echo "==> Test $scheme on $device ($id)"
    xcodebuild test -project Clink.xcodeproj -scheme "$scheme" -destination "id=$id" \
        -derivedDataPath "$DERIVED_DATA" CODE_SIGNING_ALLOWED=NO -quiet
}

case "${1:-all}" in
    lint) lint ;;
    ios) test_scheme "Clink" iOS "iPhone" ;;
    watch) test_scheme "Clink Watch App" watchOS "Apple Watch" ;;
    all)
        lint
        test_scheme "Clink" iOS "iPhone"
        test_scheme "Clink Watch App" watchOS "Apple Watch"
        ;;
    *)
        echo "Usage: $0 [lint|ios|watch|all]" >&2
        exit 2
        ;;
esac
