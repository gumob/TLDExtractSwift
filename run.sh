#!/bin/zsh

# Check if the 'fzf' command is available in the system
if ! command -v fzf &> /dev/null; then
    tput setaf 1; echo "fzf is not installed."; tput sgr0
    exit 1
fi

local option_list=(
	"clean"
	" "
	"carthage update"
	" "
	"pod cache clean --all"
	" "
	"python update-psl.py"
	" "
	"fastlane prebuild"
	"fastlane test_all"
	"fastlane build_spm"
	"fastlane build_carthage"
	"fastlane lint_cocoapods"
	"fastlane push_cocoapods"
	"fastlane set_version"
	"fastlane bump_version"
	" "
	"gem install bundler"
	"gem update bundler"
	"bundle install"
	"bundle update"
	"bundle list"
	"bundle outdated"
	"bundle clean"
)

local command=$(printf "%s\n" "${option_list[@]}" | fzf --ansi --prompt="Select a fastlane command > ")

case "$command" in
    "")         echo "No command selected" &&exit 1;;
	clean)     command="xcodebuild clean;"
				command+="xcodebuild -alltargets clean;"
				command+="xcrun --kill-cache;"
				command+="xcrun simctl erase all;"
				command+="rm -rf ~/Library/Developer/Xcode/DerivedData/;"
				;;
	"clean all")  : ;;
	carthage*)  command="carthage update --platform macos;"
				command+="carthage update --platform ios;"
				command+="carthage update --platform tvos;"
				command+="carthage update --platform watchos;"
				command+="carthage update --platform visionos;"
			   ;;
    python*)   : ;;
    fastlane*) command="bundle exec $command";;
    bundle*)   bundle config set --local clean 'true' && bundle config set --local path '.bundle' ;;
esac

# command="bundle exec $command"
echo "\n$command\n"
eval $command

exit 0