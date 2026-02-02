#!/bin/bash

# PR Title Check Script
# Validates PR titles and branch names according to project conventions

PR_TITLE="$1"
BRANCH_NAME="$2"

echo "PR Title: $PR_TITLE"
echo "Branch Name: $BRANCH_NAME"
echo ""

# Function to validate PR title
validate_pr_title() {
    local title="$1"

    # Check for [HOTFIX] prefix (optional)
    local hotfix_prefix=""
    if [[ $title =~ ^\[HOTFIX\]\ (.+)$ ]]; then
        hotfix_prefix="[HOTFIX] "
        title="${BASH_REMATCH[1]}"
        echo "ℹ️  Hotfix detected - will be included in next release"
    fi

    # Pattern 1: NUCLEUS-<number>_<description with 10+ characters>
    # Pattern 2: AUTO-<number>_<description with 10+ characters>
    # Pattern 3: Issue-<number>_<description with 10+ characters>
    if [[ $title =~ ^(NUCLEUS|AUTO|Issue)-[0-9]+_.{10,}$ ]]; then
        echo "✅ PR title format is valid!"
        return 0
    fi

    # Pattern 4: Hotfix format: <yyyymmdd>_bugfixes-<description>
    if [[ $title =~ ^[0-9]{8}_bugfixes-.{5,}$ ]]; then
        echo "✅ PR title format is valid (hotfix format)!"
        return 0
    fi

    # Pattern 5: Multiple bugfixes: bugs-<yyyymmdd>-<name>
    if [[ $title =~ ^bugs-[0-9]{8}-.{3,}$ ]]; then
        echo "✅ PR title format is valid (multiple bugfixes format)!"
        return 0
    fi

    return 1
}

# Function to validate branch name
validate_branch_name() {
    local branch="$1"

    # Skip validation for default branches
    if [[ $branch == "main" || $branch == "master" || $branch == "develop" ]]; then
        echo "ℹ️  Skipping branch name validation for default branch"
        return 0
    fi

    # Pattern 1: BitBucket - Issue-<Issue Id>_short-change-text
    if [[ $branch =~ ^Issue-[0-9]+_.{5,}$ ]]; then
        echo "✅ Branch name format is valid (BitBucket format)!"
        return 0
    fi

    # Pattern 2: Jira - NUCLEUS-<Issue Id>_short-change-text
    # Pattern 3: Jira - AUTO-<Issue Id>_short-change-text
    if [[ $branch =~ ^(NUCLEUS|AUTO)-[0-9]+_.{5,}$ ]]; then
        echo "✅ Branch name format is valid (Jira format)!"
        return 0
    fi

    # Pattern 4: Hotfixes - <yyyymmdd>_bugfixes-short-change
    if [[ $branch =~ ^[0-9]{8}_bugfixes-.{5,}$ ]]; then
        echo "✅ Branch name format is valid (hotfix format)!"
        return 0
    fi

    # Pattern 5: Multiple Bugfixes - bugs-<yyyymmdd>-<yourname>
    if [[ $branch =~ ^bugs-[0-9]{8}-.{3,}$ ]]; then
        echo "✅ Branch name format is valid (multiple bugfixes format)!"
        return 0
    fi

    return 1
}

# Validate PR title
if ! validate_pr_title "$PR_TITLE"; then
    echo "❌ PR title does not match the required format!"
    echo ""
    echo "Valid formats:"
    echo "  1. [HOTFIX] NUCLEUS-<number>_<description>  (optional [HOTFIX] prefix)"
    echo "  2. [HOTFIX] AUTO-<number>_<description>     (optional [HOTFIX] prefix)"
    echo "  3. [HOTFIX] Issue-<number>_<description>    (optional [HOTFIX] prefix)"
    echo "  4. <yyyymmdd>_bugfixes-<description>        (hotfix format)"
    echo "  5. bugs-<yyyymmdd>-<yourname>               (multiple bugfixes)"
    echo ""
    echo "Requirements:"
    echo "  - Description must be at least 10 characters for issue-based formats"
    echo "  - Description must be at least 5 characters for hotfix formats"
    echo "  - Use [HOTFIX] prefix if this was patched live on a server"
    echo ""
    echo "Examples:"
    echo "  - AUTO-123_Fix payment processing bug"
    echo "  - [HOTFIX] NUCLEUS-456_Critical security patch"
    echo "  - Issue-789_Add new user dashboard"
    echo "  - 20260202_bugfixes-auth-timeout"
    echo "  - bugs-20260202-john"
    echo ""
    echo "Your PR title: $PR_TITLE"
    exit 1
fi

# Validate branch name if provided
if [ -n "$BRANCH_NAME" ]; then
    if ! validate_branch_name "$BRANCH_NAME"; then
        echo "❌ Branch name does not match the required format!"
        echo ""
        echo "Valid formats:"
        echo "  1. Issue-<Issue Id>_short-change-text       (BitBucket)"
        echo "  2. NUCLEUS-<Issue Id>_short-change-text     (Jira)"
        echo "  3. AUTO-<Issue Id>_short-change-text        (Jira)"
        echo "  4. <yyyymmdd>_bugfixes-short-change         (Hotfixes)"
        echo "  5. bugs-<yyyymmdd>-<yourname>               (Multiple Bugfixes)"
        echo ""
        echo "Examples:"
        echo "  - Issue-123_fix-login"
        echo "  - AUTO-456_add-dashboard"
        echo "  - NUCLEUS-789_update-api"
        echo "  - 20260202_bugfixes-auth"
        echo "  - bugs-20260202-john"
        echo ""
        echo "Your branch name: $BRANCH_NAME"
        exit 1
    fi
fi

echo ""
echo "✅ All validations passed!"
exit 0

