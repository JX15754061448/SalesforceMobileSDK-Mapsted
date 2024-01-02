This is a new [**React Native**](https://reactnative.dev) project, bootstrapped using [`@react-native-community/cli`](https://github.com/react-native-community/cli).

# Getting Started

> **Note**: Make sure you have completed the [React Native - Environment Setup](https://reactnative.dev/docs/environment-setup) instructions till "Creating a new application" step, before proceeding.

## Step 1:

remove "common-mobile-lib" from “package.json”

cd SalesforceMobileSDK-Mapsted & yarn install

## Step 2:

cd ios & pod install
(if you encounter this error "Invalid `Podfile` file: undefined method `enable_user_defined_build_types!'" when execute pod install, please run "sudo gem install cocoapods-user-defined-build-types" first)

## Step 3:

Add “common-mobile-lib” into “node_modules” folder

cd ../ & yarn start

Open SalesforceMobileSDKMapsted.xcworkspace and build it
