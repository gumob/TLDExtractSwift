#!/bin/bash

executeCommand () {
	cmd=$1
    echo
	echo "$ $cmd"
    echo
	eval $cmd
	echo
}

executeCommand "bundle exec fastlane"
