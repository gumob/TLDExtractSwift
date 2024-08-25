#!/bin/zsh

# Check if the 'fzf' command is available in the system
if ! command -v fzf &> /dev/null; then
    tput setaf 1; echo "fzf is not installed."; tput sgr0;
    exit 1;
fi

local option_list=(
	"fastlane run_all"
	"fastlane tests"
	"fastlane build_spm"
	"fastlane build_carthage"
	"fastlane lint_cocoapods"
	"fastlane push_cocoapods"
	"fastlane set_version"
	"fastlane bump_version"
	" "
	"Xcode - Initialize project"
	"Xcode - Clean all build cache"
	" "
	"Carthage - Update all platforms"
	"Cocoapods - Clean all cache"
	"Public Suffix List - Download latest data"
)

local fastlane_command() {
    bundle exec $1
}

local xcode_clean() {
    xcodebuild clean || \
	xcodebuild -alltargets clean || \
	xcrun --kill-cache || \
	xcrun simctl erase all || \
	rm -rf ~/Library/Developer/Xcode/DerivedData/;
}
local xcode_init() {
    bundle_init;
	xcode_clean;
	rm -rf ./Carthage/*;
	carthage_update;
	psl_download;
}

local cocoapods_clean() {
    pod cache clean --all;
}

local psl_download() {
    python update-psl.py;
}

local carthage_update() {
    carthage update --platform macos;
	carthage update --platform ios;
	carthage update --platform tvos;
	carthage update --platform watchos;
	carthage update --platform visionos;
}

local bundle_init() {
    rm -rf .bundle;
	rm -rf Gemfile.lock;
	gem install bundler;
	bundle install;
	bundle update;
	bundle exec fastlane add_plugin versioning;
}

local selected_option=$(printf "%s\n" "${option_list[@]}" | fzf --ansi --prompt="Select a job to execute > ")

case "$selected_option" in
    fastlane*)                                   fastlane_command $selected_option;;
	"Xcode - Initialize project")                xcode_init;;
	"Xcode - Clean all build cache")             xcode_clean;;
	"Cocoapods - Clean all cache")               cocoapods_clean;;
	"Carthage - Update all platforms")           carthage_update;;
	"Public Suffix List - Download latest data") psl_download;;
	*)                                           echo "Invalid option $selected_option" && exit 1;;
esac

exit 0;