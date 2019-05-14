#!/usr/bin/env bash

cat .git-hooks/pre-commit > .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
cat .git-hooks/pre-push > .git/hooks/pre-push && chmod +x .git/hooks/pre-push
