fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### Run all jobs

```sh
bundle exec fastlane run_all
```

### Set version number

```sh
bundle exec fastlane set_version
```

### Bump version number

```sh
bundle exec fastlane bump_version
```

### Run all tests

```sh
bundle exec fastlane tests
```

### Build SPM

```sh
bundle exec fastlane build_spm
```

### Build Carthage

```sh
bundle exec fastlane build_carthage
```

### Lint Cocoapods

```sh
bundle exec fastlane lint_cocoapods
```

### Push Cocoapods

```sh
bundle exec fastlane push_cocoapods
```

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
