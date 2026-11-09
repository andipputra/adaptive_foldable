# adaptive_foldable

A design-agnostic Flutter navigation scaffold with a fold kit.

## Overview

`adaptive_foldable` resolves device posture, display features, size classes, and iOS `verticalBarEdge` into a single resolved navigation layout. It provides a flexible builder API allowing apps to bring their own navigation bar design or use platform-adaptive defaults across mobile, tablet, and foldable devices (including iPhone Duo and Android foldables).

## Workspace Structure

- `packages/adaptive_foldable/`: The core plugin package (`flutter` runtime dependency only).
- `packages/adaptive_foldable/example/`: Example demonstration application.

## Toolchain Notes

### iOS Deployment Target
iOS deployment target is 15.0 or higher. In your iOS `Podfile`, ensure the platform is set accordingly:
```ruby
platform :ios, '15.0'
```

### Xcode 27.1+ and Simulator Builds
- Compiling against iPhone Duo APIs requires Xcode 27.1 or later.
- If dual-architecture simulator builds encounter `lipo` issues on older Flutter toolchains, restrict simulator architectures in Podfile or Xcode build settings:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
```
