#!/bin/bash
# SessionStart Hook - Auto-run on new Claude Code session
# Purpose: Initialize Flutter environment for social_quiz_app

set -e

echo "🚀 social_quiz_app: SessionStart Hook"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Step 1: flutter pub get
echo "📦 Step 1: Fetching dependencies..."
if ! flutter pub get 2>/dev/null; then
    echo "⚠️  flutter pub get failed. Retrying..."
    flutter pub get --no-precompile
fi
echo "✅ Dependencies fetched"

# Step 2: flutter analyze
echo "📝 Step 2: Running analyzer..."
if flutter analyze --no-preamble 2>/dev/null | head -20; then
    echo "✅ Analyze complete"
else
    echo "⚠️  Analyze had warnings/errors (see above)"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SessionStart Hook complete!"
echo ""
echo "📌 Next: Run emulator tests"
echo "   /build-and-test social_quiz_app"
