#!/bin/bash

# Direct test runner without scheme test plans
# This script works even if test plans are not added to Xcode scheme

set -e

PROJECT="Timer.xcodeproj"
SCHEME="Timer"
DESTINATION="platform=iOS Simulator,name=iPhone 17 Pro"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🧪 Running Timer Tests${NC}"
echo ""

case "$1" in
    unit|"")
        echo "Running Unit Tests only..."
        xcodebuild test \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -only-testing:TimerTests \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO
        ;;

    all)
        echo "Running All Tests (Unit + UI)..."
        xcodebuild test \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO
        ;;

    models)
        echo "Running Models Tests only..."
        xcodebuild test \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -only-testing:TimerTests/BoxingTimerModelTests \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO
        ;;

    viewmodels)
        echo "Running ViewModels Tests only..."
        xcodebuild test \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -only-testing:TimerTests/StatusDisplayTests \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO
        ;;

    utils)
        echo "Running Utils Tests only..."
        xcodebuild test \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -only-testing:TimerTests/TimeFormatterTests \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO
        ;;

    integration)
        echo "Running Integration Tests only..."
        xcodebuild test \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -only-testing:TimerTests/StateTransitionTests \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO
        ;;

    coverage)
        echo "Running tests with code coverage..."
        xcodebuild test \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -only-testing:TimerTests \
            -enableCodeCoverage YES \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO
        ;;

    *)
        echo "Usage: $0 [test-type]"
        echo ""
        echo "Available test types:"
        echo "  (none)        - Run unit tests (default)"
        echo "  unit          - Run all unit tests"
        echo "  all           - Run all tests (unit + UI)"
        echo "  models        - Run Models layer tests only"
        echo "  viewmodels    - Run ViewModels layer tests only"
        echo "  utils         - Run Utils layer tests only"
        echo "  integration   - Run Integration layer tests only"
        echo "  coverage      - Run tests with code coverage"
        echo ""
        echo "Examples:"
        echo "  $0"
        echo "  $0 unit"
        echo "  $0 models"
        echo "  $0 coverage"
        exit 1
        ;;
esac

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Tests passed!${NC}"
else
    echo ""
    echo -e "❌ Tests failed!"
    exit 1
fi
