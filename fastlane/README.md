fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios build

```sh
[bundle exec] fastlane ios build
```

Buils App without bitcode

### ios set_appicon

```sh
[bundle exec] fastlane ios set_appicon
```

Set App Icon from design

### ios manage_provision

```sh
[bundle exec] fastlane ios manage_provision
```

Fetching or creating certificates in Apple Developer

### ios update_project

```sh
[bundle exec] fastlane ios update_project
```

Updating project Team ID and Provision Profiles

### ios update_pods

```sh
[bundle exec] fastlane ios update_pods
```

Updating pods

### ios submit_build

```sh
[bundle exec] fastlane ios submit_build
```

Upload metadata, screenshots and build to App Store Connect, then sumbit for review

### ios appstore_submit

```sh
[bundle exec] fastlane ios appstore_submit
```

Build, sign and upload a new build to the App Store.

This will do the following:



- Create new screenshots and store them in `./fastlane/screenshots`

- Collect the app metadata from `./fastlane/metadata`

- Upload screenshots + app metadata

- Build, sign and upload the app

- Submit the app for review

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
