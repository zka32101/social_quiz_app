#!/bin/bash
# Android Emulator Setup Script
# This script sets up and configures an Android emulator for testing Flutter apps

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration variables
API_LEVEL=${API_LEVEL:-30}
ARCH=${ARCH:-x86_64}
AVD_NAME=${AVD_NAME:-flutter_test_device}
EMULATOR_TIMEOUT=${EMULATOR_TIMEOUT:-300}

echo -e "${GREEN}=== Android Emulator Setup ===${NC}"

# Check if Android SDK is installed
if [ -z "$ANDROID_HOME" ]; then
    echo -e "${RED}Error: ANDROID_HOME environment variable is not set${NC}"
    exit 1
fi

echo -e "${GREEN}✓ ANDROID_HOME is set: $ANDROID_HOME${NC}"

# Check if emulator exists, create if not
if [ -d "$ANDROID_HOME/avd/$AVD_NAME.avd" ]; then
    echo -e "${GREEN}✓ AVD $AVD_NAME already exists${NC}"
else
    echo -e "${YELLOW}Creating AVD: $AVD_NAME (API Level $API_LEVEL, Architecture: $ARCH)${NC}"

    # Create system image if it doesn't exist
    $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --install "system-images;android-$API_LEVEL;google_apis;$ARCH" --channel=0

    # Create AVD
    echo "no" | $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd \
        -n "$AVD_NAME" \
        -k "system-images;android-$API_LEVEL;google_apis;$ARCH" \
        --force

    echo -e "${GREEN}✓ AVD created successfully${NC}"
fi

# Configure emulator settings for CI environment
echo -e "${YELLOW}Configuring emulator settings...${NC}"

AVD_CONFIG_PATH="$ANDROID_HOME/avd/$AVD_NAME.avd/config.ini"
if [ -f "$AVD_CONFIG_PATH" ]; then
    # Disable animations and graphics for faster execution
    sed -i.bak '/^hw.lcd.density/d' "$AVD_CONFIG_PATH"
    echo "hw.lcd.density=240" >> "$AVD_CONFIG_PATH"

    sed -i.bak '/^hw.gpu.enabled/d' "$AVD_CONFIG_PATH"
    echo "hw.gpu.enabled=yes" >> "$AVD_CONFIG_PATH"

    sed -i.bak '/^hw.gpu.mode/d' "$AVD_CONFIG_PATH"
    echo "hw.gpu.mode=swiftshader_indirect" >> "$AVD_CONFIG_PATH"

    echo -e "${GREEN}✓ Emulator configured${NC}"
fi

# Display emulator info
echo -e "${GREEN}=== Emulator Information ===${NC}"
echo "AVD Name: $AVD_NAME"
echo "API Level: $API_LEVEL"
echo "Architecture: $ARCH"
echo "Config: $AVD_CONFIG_PATH"
echo ""
echo -e "${GREEN}✓ Setup complete!${NC}"
echo -e "${YELLOW}Note: Use 'reactivecircus/android-emulator-runner' action in CI workflows${NC}"
echo -e "${YELLOW}      or manually start with: emulator -avd $AVD_NAME${NC}"
