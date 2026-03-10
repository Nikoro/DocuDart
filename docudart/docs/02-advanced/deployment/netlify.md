---
title: Netlify
sidebar_position: 2
---

# Deploy to Netlify

## Setup

1. Connect your repository to Netlify
2. Configure the build settings:
   - **Build command**: `dart pub get --no-example && dart run bin/docudart.dart build`
   - **Publish directory**: `docudart/build/web/`

## Dart SDK

Netlify doesn't include Dart by default. Add a `netlify.toml` to your repository root:

```toml
[build]
  command = "dart pub get --no-example && dart run bin/docudart.dart build"
  publish = "docudart/build/web/"

[build.environment]
  DART_VERSION = "stable"
```

You may need a build plugin or custom install script to set up the Dart SDK. Alternatively, use a pre-built approach: run `docudart build` locally or in CI, commit the output, and point Netlify to the static directory.

## Custom domain

Configure your custom domain in Netlify's **Domain management** settings. Netlify handles SSL automatically.

## SEO

Set `siteUrl` in your `config.dart`:

```dart
siteUrl: 'https://docs.example.com',
```
