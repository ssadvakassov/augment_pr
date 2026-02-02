#!/bin/bash

# PR Title Check Script
# Pattern: AUTO-<number>_<string with length more than 10 characters>

PR_TITLE="$1"

echo "PR Title: $PR_TITLE"

# Pattern: AUTO-<number>_<description with 10+ characters>
if [[ $PR_TITLE =~ ^AUTO-[0-9]+_.{10,}$ ]]; then
    echo "✅ PR title format is valid!"
    exit 0
else
    echo "❌ PR title does not match the required format!"
    echo ""
    echo "Required format: AUTO-<number>_<description>"
    echo ""
    echo "Requirements:"
    echo "  - Must start with 'AUTO-'"
    echo "  - Followed by a number"
    echo "  - Then an underscore '_'"
    echo "  - Then a description with at least 10 characters"
    echo ""
    echo "Example: AUTO-123_This is a valid PR title"
    echo ""
    echo "Your PR title: $PR_TITLE"
    exit 1
fi

