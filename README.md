# arata

A faithful reimplementation of the [apollo](https://github.com/not-matthias/apollo) blog theme, built with [Gleam](https://gleam.run) and the [Lustre](https://hexdocs.pm/lustre) framework.

arata reproduces apollo's minimal, typography-driven aesthetic as a client-side single-page application: content is authored in Markdown, parsed at build time by [mork](https://hex.pm/packages/mork) (a pure-Gleam CommonMark + GFM parser), and served to a Lustre SPA that fetches a single `content_index.json` at runtime. No file system access happens in the browser.

> **Status:** v0.1.0. The build pipeline reads `.md` files under `content/`, renders them to HTML via mork, and emits a complete static site in `dist/`.

## Stack

- **Language:** Gleam (compiles to JavaScript)
- **Framework:** Lustre (The Elm Architecture, client-side SPA)
- **Routing:** modem (History API)
- **Markdown:** mork + mork_to_lustre (pure-Gleam CommonMark + GFM)
- **HTTP:** rsvp (browser `fetch` for `content_index.json`)
- **Frontmatter / files:** tom (TOML parser), simplifile (build-time file I/O)
- **JSON:** gleam_json
- **Build/dev:** lustre_dev_tools + `bun build` (no Erlang/OTP required)

## Features

- **File-based content model** — posts, pages, links, and projects are `.md` files under `content/` with TOML frontmatter.
- **mork markdown rendering** — every Markdown body is parsed by mork at build time and stored as pre-rendered HTML in `content_index.json`.
- **9 routes**: `/`, `/posts`, `/posts/{slug}`, `/projects`, `/links`, `/tags`, `/tags/{name}`, `/{slug}` (standalone pages), and a 404.
- **3-state theme toggle** (Light / Dark / Auto) with `localStorage` persistence and `prefers-color-scheme` reactivity.
- **Cmd/Ctrl+K search** modal with keyboard navigation (toggle with `search_enabled`).
- **Table of contents** with scroll-driven `IntersectionObserver` highlighting.
- **Fancy code blocks** with copy button + language label.
- **4 shortcodes**: `note`, `character`, `image`, `mermaid`.
- **MathJax + Mermaid** rendering with theme-aware re-rendering.
- **SEO** meta, OpenGraph, Atom/RSS feeds, sitemap.
- **Analytics**: GoatCounter, Umami (Google Analytics intentionally not supported).
- **Comments**: Giscus, Utterances.
- **Modular CSS** — 10 modules under `src/css/` concatenated at build time into a single `dist/arata.css`.
- **Accent color** `#3555b3` (dark blue), editable in a single CSS variable.
- **Build pipeline**: `gleam run -m build/pipeline` → complete static site in `dist/`.

## Quick start

```sh
# Type-check and compile the project.
gleam build

# Run the test suite.
gleam test

# Build a complete static site into dist/.
gleam run -m build/pipeline

# Serve dist/ locally and open it in a browser.
python -m http.server --directory dist
```

The build pipeline is self-contained: it reads the `.md` files under `content/`, parses the TOML frontmatter with `tom`, renders the Markdown bodies with `mork`, serializes everything to `dist/content_index.json` (and `dist/search_index.json`), emits feeds/sitemap, concatenates the CSS modules into `dist/arata.css`, copies `static/` to `dist/`, and bundles the SPA into `dist/app.mjs` via `bun build`.

At runtime, the SPA fetches `/content_index.json` once on boot (`rsvp`), decodes it with `gleam/dynamic/decode`, and hands the typed content tree to the Lustre view layer. The browser never touches the file system.

## Project layout

```
arata/
├── src/
│   ├── arata.gleam            # entry point (boots Lustre)
│   ├── route.gleam            # URL <-> Route mapping (modem)
│   ├── config.gleam           # Config type + defaults (title, menu, socials, fonts, ...)
│   ├── data/                  # content models + SiteMeta
│   │   ├── site.gleam         # SiteMeta, Analytics, CommentsConfig types
│   │   ├── post.gleam         # Post type
│   │   ├── project.gleam      # Project type
│   │   ├── link.gleam         # Link type
│   │   ├── page.gleam         # Page type
│   │   └── markdown.gleam     # mork -> HTML wrapper
│   ├── content/
│   │   ├── loader.gleam       # build-time .md reader (simplifile + tom + mork)
│   │   └── runtime.gleam      # browser-side content_index.json fetch (rsvp)
│   ├── view/                  # page + component views
│   ├── effect/                # managed side effects (FFI)
│   ├── ffi/                   # JavaScript FFI
│   ├── shortcodes/            # note, character, image, mermaid
│   ├── build/                 # content -> dist/ pipeline + feeds
│   │   ├── pipeline.gleam     # orchestrator
│   │   └── feeds.gleam        # atom.xml, rss.xml, sitemap.xml
│   └── css/                   # 10 CSS modules (concatenated at build time)
│       ├── base.css           # @font-face, theme vars, html/body, headings, links
│       ├── layout.css         # .arata-shell, .content, .left/.right-content, nav, .logo
│       ├── components.css     # .page-header, .post-list, .pagination, .icon-button, .tags, ...
│       ├── post.css           # blockquote, .tldr, img/figure, table, .mermaid, .note-*, code, .label-*
│       ├── cards.css          # .cards, .card-*, talks grid
│       ├── links.css          # .link-avatar (friend-link avatars)
│       ├── search.css         # .search-button, .search-modal, #results, ...
│       ├── toc.css            # .toc, .heading, .selected, .parent
│       ├── syntax.css         # giallo light/dark syntax highlighting
│       └── accessibility.css  # :focus-visible outlines + .skip-link
├── content/                   # file-based content (authored Markdown)
│   ├── posts/*.md             # blog posts
│   ├── pages/*.md             # standalone pages (incl. home.md, about.md)
│   ├── links/*.md             # friend-link cards
│   └── projects/*.md          # project showcase cards
├── static/                    # fonts, icons, images, vendored CSS
├── test/                      # unit tests
├── gleam.toml
├── manifest.toml
├── ROADMAP.md
└── CHANGELOG.md
```

## Content authoring

All content lives under `content/` in four subdirectories. Each Markdown file uses **TOML frontmatter** delimited by `+++ … +++`:

```
+++
title = "Hello, arata"
date = "2026-01-15"
description = "Introducing arata."
tags = ["gleam", "lustre"]
+++

Body in Markdown — parsed by mork at build time.
```

| Directory               | Type    | Frontmatter                                                          |
|-------------------------|---------|----------------------------------------------------------------------|
| `content/posts/*.md`    | Post    | `title`, `date`, `updated`?, `description`, `tags`?, `draft`?, `tldr`? |
| `content/pages/*.md`    | Page    | `title`, `subtitle`?                                                  |
| `content/links/*.md`    | Link    | `title`, `url`, `description`, `image`?                              |
| `content/projects/*.md` | Project | `title`, `description`, `link_to`?, `image`?, `github`?, `demo`?, `tags`? |

The Markdown body is rendered to HTML by mork at build time and stored (pre-rendered) in `content_index.json`. The SPA fetches this JSON once at boot — there is no Markdown parsing in the browser.

## Configuration

arata is configured through two Gleam modules:

- **`src/config.gleam`** — the `Config` type: `title`, `description`, `menu`, `socials`, `logo`, `fonts`, `rss_enabled`, `search_enabled`, `analytics`.
- **`src/data/site.gleam`** — the `SiteMeta` type: `base_url`, `title`, `description`, `analytics`, `comments`, `fediverse_creator`, `rss_enabled`.

Highlights:

- **`rss_enabled`** (`Bool`) — when `False`, no `atom.xml` / `rss.xml` are written, no feed `<link>` tags are emitted, and the RSS social is dropped from the header.
- **`search_enabled`** (`Bool`) — when `False`, the search button, modal, and `Cmd/Ctrl+K` shortcut are all omitted.
- **`fonts`** — a `Fonts(text, header, code)` record of CSS `font-family` declarations. Defaults to system font stacks.
- **`analytics`** — `AnalyticsDisabled`, `GoatCounter(user, host)`, or `Umami(website_id, host_url)`. Google Analytics is intentionally not supported.
- **Accent color** — edit `--primary-color: #3555b3;` in `src/css/base.css` to recolor every accent surface.

See [`content/posts/configuration.md`](./content/posts/configuration.md) for the full configuration guide.

## Deployment

`gleam run -m build/pipeline` produces a complete static site in `dist/`:

```
dist/
├── index.html              # SPA shell with feed <link> tags
├── 404.html                # redirect shim for SPA deep-linking
├── app.mjs                 # bundled Lustre SPA
├── arata.css               # concatenated CSS (10 modules)
├── content_index.json      # content manifest fetched by the SPA
├── search_index.json       # search corpus (when search_enabled)
├── atom.xml                # Atom feed (when rss_enabled)
├── rss.xml                 # RSS 2.0 feed (when rss_enabled)
├── sitemap.xml
├── css/                    # vendored theme stylesheets
├── fonts/
├── icons/
└── images/
```

Serve `dist/` with any static file host (GitHub Pages, Cloudflare Pages, Netlify, `python -m http.server`, etc.). The included `404.html` redirects unknown paths back into the SPA so client-side routing handles deep links.

## Origin

`arata` reproduces the design and feature set of the `apollo` Zola theme as a Gleam/Lustre SPA. See [`ROADMAP.md`](./ROADMAP.md) for the full mapping from apollo's templates and SCSS to Lustre views and plain CSS.

## License

MIT
