#!/bin/zsh

local option_list=(
	"bundle install"
	"bundle update"
	"bundle list"
	"bundle outdated"
	"bundle clean"
	"gem update bundler"
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

bundle config set --local clean 'true'
bundle config set --local path '.bundle'

# command="bundle exec $command"
echo "\n$command\n"
eval $command

exit 0