#!/bin/zsh

# Check if the 'fzf' command is available in the system
if ! command -v fzf &> /dev/null; then
    tput setaf 1; echo "fzf is not installed."; tput sgr0;
    exit 1;
fi

local option_list=(
	"fastlane run_all"
	"fastlane lint_swift"
	"fastlane tests"
	"fastlane build_spm"
	"fastlane build_carthage"
	"fastlane lint_cocoapods"
	"fastlane push_cocoapods"
	"fastlane gen_docs"
	"fastlane set_version"
	"fastlane bump_version"
	" "
	"Xcode - Initialize project"
	"Xcode - Clean all build cache"
	" "
	"Carthage - Update all platforms"
	"Cocoapods - Clean all cache"
	"Cocoapods - Trunk push"
	" "
	"Github - Update tag"
)

local fastlane_command() {
    bundle exec $1
}

local xcode_clean() {
    xcodebuild clean || \
	xcodebuild -alltargets clean || \
	xcrun --kill-cache || \
	xcrun simctl erase all || \
	rm -rf ~/Library/Developer/Xcode/DerivedData/*;
}
local xcode_init() {
    bundle_init;
	xcode_clean;
	rm -rf ./Carthage/*;
	carthage_update;
	psl_download;
}

local carthage_update() {
    carthage update --platform macos;
	carthage update --platform ios;
	carthage update --platform tvos;
	carthage update --platform watchos;
	carthage update --platform visionos;
}

local cocoapods_clean() {
    pod cache clean --all;
}

local cocoapods_trunk_push() {
	# Enable error handling and exit the script on pipe failures
	set -eo pipefail
	# Check if the current branch is 'main'
	if [[ $(git rev-parse --abbrev-ref HEAD) != "main" ]]; then
		echo "Warning: You are not on the main branch. Please switch to the main branch and run again."
		exit 1
	fi
	# Find the project name and podspec name
	project_name=$(find . -maxdepth 1 -name "*.xcodeproj" -exec basename {} .xcodeproj \;)
	podspec_name=$(find . -maxdepth 1 -name "*.podspec" -exec basename {} .podspec \;)
	# Retrieve the current version from the project file
	current_version=$(grep -m1 'MARKETING_VERSION' "${project_name}.xcodeproj/project.pbxproj" | sed 's/.*= //;s/;//')
	echo "Current version: $current_version"
	# Check if the current version is a valid semantic version
	if [[ ! "$current_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		echo "Error: Invalid version number"
		exit 1
	fi
	# Check if the current version already exists in the CocoaPods trunk
	if pod trunk info ${podspec_name} | grep -q "$current_version"; then
		echo "Start deleting $current_version"
		# Delete the existing version from the CocoaPods trunk
		echo "y" | pod trunk delete ${podspec_name} $current_version || true
	fi
	echo "Start pushing $current_version"
	# Push the new version to the CocoaPods trunk
	pod trunk push ${podspec_name}.podspec --allow-warnings
}

local github_update_tag() {
	# Enable error handling and exit the script on pipe failures
	set -eo pipefail
	# Check if the current branch is 'main'
	if [[ $(git rev-parse --abbrev-ref HEAD) != "main" ]]; then
		echo "Warning: You are not on the main branch. Please switch to the main branch and run again."
		exit 1
	fi
	# Find the project name and podspec name
	project_name=$(find . -maxdepth 1 -name "*.xcodeproj" -exec basename {} .xcodeproj)
	podspec_name=$(find . -maxdepth 1 -name "*.podspec" -exec basename {} .podspec)
	# Retrieve build settings and execute a command to filter MARKETING_VERSION
	current_version=$(grep -m1 'MARKETING_VERSION' "${project_name}.xcodeproj/project.pbxproj" | sed 's/.*= //;s/;//')
	echo "Current version: $current_version"
	# If the current version is found
	if [[ $current_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		# Check if a tag for the current version already exists
		if git tag -l | grep -q "$current_version"; then
			# If the tag exists, delete it from both local and remote
			git tag -d "$current_version"
			git push origin ":refs/tags/$current_version"
		fi
		# Create a new tag for the current version and push it to the remote repository
		git tag "$current_version"
		git push origin "$current_version"
	else
		# If the version could not be retrieved, display an error message
		echo "Error: Could not retrieve the version."
	fi
}

local psl_download() {
    python update-psl.py;
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
	"Carthage - Update all platforms")           carthage_update;;
	"Cocoapods - Clean all cache")               cocoapods_clean;;
	"Cocoapods - Trunk push")                    cocoapods_trunk_push;;
	"Github - Update tag")                       github_update_tag;;
	*)                                           echo "Invalid option $selected_option" && exit 1;;
esac

exit 0;