#!/bin/bash

# Test Runner Script for Timer Project
# Usage: ./run-tests.sh [plan-name]
# Example: ./run-tests.sh smoke

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT="Timer.xcodeproj"
SCHEME="Timer"
DESTINATION="platform=iOS Simulator,name=iPhone 17 Pro"

# Function to print colored output
print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to run tests
run_test_plan() {
    local plan=$1
    local plan_file="${plan}.xctestplan"

    if [ ! -f "$plan_file" ]; then
        print_error "Test plan '$plan_file' not found!"
        exit 1
    fi

    print_info "Running test plan: $plan"
    print_info "Using scheme: $SCHEME"
    print_info "Destination: $DESTINATION"
    echo ""

    # Build and test
    xcodebuild clean test \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -testPlan "$plan" \
        2>&1 | xcpretty || xcodebuild clean test \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -testPlan "$plan"

    if [ $? -eq 0 ]; then
        print_success "Tests passed for plan: $plan"
    else
        print_error "Tests failed for plan: $plan"
        exit 1
    fi
}

# Main script
case "$1" in
    unit|UnitOnly)
        run_test_plan "UnitOnly"
        ;;
    ci|CI)
        run_test_plan "CI"
        ;;
    all|AllTests)
        run_test_plan "AllTests"
        ;;
    smoke|Smoke)
        run_test_plan "Smoke"
        ;;
    perf|performance|Performance)
        run_test_plan "Performance"
        ;;
    regression|Regression)
        run_test_plan "Regression"
        ;;
    *)
        echo "Timer Project Test Runner"
        echo ""
        echo "Usage: $0 [plan-name]"
        echo ""
        echo "Available test plans:"
        echo "  unit          - Fast unit tests only (~0.1s)"
        echo "  ci            - CI/CD optimized tests with coverage (~0.1s)"
        echo "  all           - All tests including UI (~45s)"
        echo "  smoke         - Critical smoke tests (~0.06s)"
        echo "  performance   - Performance benchmark tests (~0.03s)"
        echo "  regression    - Full regression suite (~55s)"
        echo ""
        echo "Examples:"
        echo "  $0 unit"
        echo "  $0 smoke"
        echo "  $0 all"
        exit 1
        ;;
esac
