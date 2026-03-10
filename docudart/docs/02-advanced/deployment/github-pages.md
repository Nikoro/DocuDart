---
title: GitHub Pages
sidebar_position: 1
---

# Deploy to GitHub Pages

## GitHub Actions workflow

Create `.github/workflows/docs.yaml` in your repository:

```yaml
name: Deploy Docs

on:
  push:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
      - uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('pubspec.lock') }}
          restore-keys: ${{ runner.os }}-pub-
      - run: dart pub get --no-example
      - run: dart run bin/docudart.dart build
      - uses: actions/upload-pages-artifact@v3
        with:
          path: docudart/build/web/

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

## Enable GitHub Pages

1. Go to your repository **Settings > Pages**
2. Under **Source**, select **GitHub Actions**
3. Push to `main` — the workflow will build and deploy your docs

## Custom domain

To use a custom domain (e.g., `docs.example.com`):

1. Add a CNAME step to the workflow after the build step:

```yaml
      - run: echo "docs.example.com" > docudart/build/web/CNAME
```

2. Configure DNS at your domain registrar:
   - **Apex domain** (e.g., `example.com`): Add 4 A records:
     - `185.199.108.153`
     - `185.199.109.153`
     - `185.199.110.153`
     - `185.199.111.153`
   - **Subdomain** (e.g., `docs.example.com`): Add a CNAME record pointing to `<username>.github.io`

3. In your repository **Settings > Pages**, set the custom domain and enable **Enforce HTTPS**

## SEO

Set `siteUrl` in your `config.dart` to enable canonical URLs, Open Graph tags, sitemap, and robots.txt:

```dart
siteUrl: 'https://docs.example.com',
```
