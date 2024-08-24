#!/bin/zsh

local option_list=(
	"fastlane prebuild"
	"fastlane test_all"
	"fastlane build_spm"
	"fastlane build_carthage"
	"fastlane lint_cocoapods"
	"fastlane push_cocoapods"
	"fastlane set_version"
	"fastlane bump_version"
)

if ! command -v fzf &> /dev/null; then
    tput setaf 1; echo "fzf is not installed."; tput sgr0
    exit 1
fi

local command=$(printf "%s\n" "${option_list[@]}" | fzf --ansi --prompt="Select a fastlane command > ")

if [ -z "$command" ]; then
	echo "No command selected"
	exit 1
fi

command="bundle exec $command"
echo "\n$command\n"
eval $command

exit 0