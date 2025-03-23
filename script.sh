#!/bin/bash

if test -t 1; then
    ncolors=$(tput colors)
    if test -n "$ncolors" && test $ncolors -ge 8; then
        GREEN='\033[0;32m'
        YELLOW='\033[0;33m'
        NC='\033[0m' # No Color
    else
        GREEN=''
        YELLOW=''
        NC=''
    fi
else
    GREEN=''
    YELLOW=''
    NC=''
fi

HOOKS=("post-merge" "post-commit" "post-rewrite")

for HOOK in "${HOOKS[@]}"; do
    HOOK_PATH=".git/hooks/$HOOK"
    if [ ! -f "$HOOK_PATH" ]; then
        echo -e "${GREEN}Installing $HOOK hook...${NC}"
        cp "$0" "$HOOK_PATH"
        chmod +x "$HOOK_PATH"
    fi
done

if [ "$1" = "rebase" ]; then
    CHANGED_FILES=$(git diff --name-only ORIG_HEAD HEAD)
else
    CHANGED_FILES=$(git diff --name-only HEAD@{1} HEAD)
fi

if echo "$CHANGED_FILES" | grep -q "package.json"; then
    echo -e "${GREEN}👉 package.json changed. Running npm install...${NC}"
    npm install
fi

if echo "$CHANGED_FILES" | grep -q "composer.json"; then
    echo -e "${GREEN}👉 composer.json changed. Running composer install...${NC}"
    composer install --no-interaction --prefer-dist
fi

if echo "$CHANGED_FILES" | grep -q "database/migrations/"; then
    echo -e "${GREEN}👉 Migrations changed. Running artisan migrate...${NC}"
    php artisan migrate
fi

if echo "$CHANGED_FILES" | grep -q ".env.example"; then
    echo -e "${YELLOW}⚠ .env.example changed. Please check for updated credentials!${NC}"
fi