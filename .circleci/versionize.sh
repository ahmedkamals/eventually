#!/usr/bin/env bash

set -o errexit
set -o nounset
set -euo pipefail

mkdir -p "$HOME/.ssh/" && echo -e "Host github.com\n\tStrictHostKeyChecking no\n" > ~/.ssh/config

LAST_COMMIT_MESSAGE=$(git log -1 --pretty=%B)
VERSION_FILE="./.version"
touch "$VERSION_FILE"

versionize() {
    local commit_message="$1"
    local major="$2"
    local minor="$3"
    local patch="$4"
    local version_file="$5"

    if echo "$commit_message" | grep -iqE "\[major\]"; then
      major=$((major+1))
      echo "v$major.0.0" > "$version_file"
    elif echo "$commit_message" | grep -iqE "\[minor\]"; then
      minor=$((minor+1))
      echo "v$major.$minor.0" > "$version_file"
    elif echo "$commit_message" | grep -iqE "\[patch\]"; then
      patch=$((patch+1))
      echo "v$major.$minor.$patch" > "$version_file"
    fi
}

if VERSION=$(git describe --abbrev=0 --tags 2> /dev/null) && [[ (-n "$(git diff "$VERSION")") || (-z "$VERSION") ]]; then
  VERSION=${VERSION:-'0.0.0'}; VERSION=${VERSION#"v"}
  MAJOR=${VERSION%%.*}; VERSION=${VERSION#*.}
  MINOR=${VERSION%%.*}; VERSION=${VERSION#*.}
  PATCH=${VERSION%%.*}; VERSION=${VERSION#*.}

  versionize "$LAST_COMMIT_MESSAGE" "$MAJOR" "$MINOR" "$PATCH" "$VERSION_FILE"
else
  versionize "$LAST_COMMIT_MESSAGE" 0 0 0 "$VERSION_FILE"
fi
