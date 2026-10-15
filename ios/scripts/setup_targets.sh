#!/bin/sh
# Runs setup_targets.rb with Homebrew Ruby and the xcodeproj gem bundled with Homebrew CocoaPods.
set -e
POD=$(brew --prefix cocoapods)/libexec
GEM_HOME="$POD" exec "$(brew --prefix ruby)/bin/ruby" "$(dirname "$0")/setup_targets.rb"
