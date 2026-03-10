---
title: Getting Started
sidebar_position: 1
---

# Getting Started

DocuDart is a static documentation generator for Dart projects, powered by [Jaspr](https://pub.dev/packages/jaspr). Write your docs in Markdown with YAML frontmatter, and DocuDart generates a fast, responsive static website.

## Features

- **Markdown-first** — Write docs in Markdown with YAML frontmatter
- **Live reload** — Instant preview with `docudart serve`
- **Light & dark mode** — System preference detection with manual toggle
- **Responsive design** — Mobile sidebar drawer, CSS breakpoints via `context.screen`
- **Flutter-like API** — `Row`, `Column`, `IconButton`, `Padding` — looks like Flutter, outputs HTML/CSS/JS
- **52,000+ icons** — 7 icon families (Material, Lucide, Tabler, Font Awesome, Fluent, Remix, Material Symbols)
- **Collapsible sidebar** — Auto-generated from folder structure with `_expanded` suffix control
- **Type-safe config** — `config.dart` with full IntelliSense, not YAML
- **Custom pages** — Add Jaspr components to `pages/` for landing pages, changelogs, etc.
- **Type-safe assets** — `context.project.assets.logo.logo_webp` auto-generated from your `assets/` directory
- **Theming** — 3 built-in presets (Classic, Material 3, shadcn) with seed color support
- **Auto-discovered pages** — Just add a `.dart` file to `pages/` and link to it

## Installation

```bash
dart pub global activate docudart
```

## Create a project

Inside your Dart project directory:

```bash
docudart create --full
```

This creates a `docudart/` subdirectory with config, docs, components, pages, and assets.

You can also specify a custom folder name:

```bash
docudart create my_docs --full
```

## Preview locally

```bash
docudart serve
```

Open `http://localhost:8080` — changes to docs, config, and components reload automatically.

## Build for production

```bash
docudart build
```

Output goes to `docudart/build/web/` — ready to deploy to any static hosting.
