#!/bin/bash

rm -f .git/hooks/pre-commit
cp scripts/git/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

rm -f .git/hooks/commit-msg
cp scripts/git/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
