#!/bin/bash
# Android Emulator Test Script
# This script runs Flutter tests on the Android emulator

set -e

WORKING_DIR=${1:-.}

echo "=== Flutter Integration Tests on Android Emulator ==="
echo "Working Directory: $WORKING_DIR"

cd "$WORKING_DIR"

# Check if tests exist
if [ ! -d "test_driver" ] && [ ! -d "integration_test" ]; then
    echo "Warning: No integration tests found (test_driver/ or integration_test/)"
    echo "Running regular flutter test instead..."
    flutter test --coverage
    exit 0
fi

# Run integration tests
if [ -d "integration_test" ]; then
    echo "Running integration tests..."
    flutter drive \
        --driver=test_driver/integration_test.dart \
        --target=integration_test/app_test.dart \
        --debug
elif [ -d "test_driver" ]; then
    echo "Running test_driver tests..."
    flutter drive \
        --target=test_driver/app.dart \
        --debug
fi

echo "=== Tests completed successfully ==="
