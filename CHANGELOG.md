# Changelog

All notable changes to arata are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Search backdrop**: click outside the search modal to close it, via a CSS overlay backdrop rendered behind the modal.
- **Mobile menu**: hamburger button visible below 992px that toggles a vertical dropdown of nav links.
- **Tags menu item**: a "tags" entry added to the navbar for direct access to `/tags`.
- **Tags heading in sidebar**: a "Tags" label rendered above each post's tag list.
- **Link avatars**: optional `image` field on the `Link` type, rendered as a circular avatar on the links page.
- **Multi-level table of contents**: the ToC now parses `h2`, `h3`, and `h4` headings from the rendered HTML into a nested tree (previously single-level).
- **Bundle size analysis**: production bundle measured at 115 KB minified (32 KB gzipped), well-optimised for an SPA of this scope.
- Config: `mathjax_enabled` flag (default False) to enable/disable MathJax rendering.
- Optional font support documented: Maple Font and Sarasa Gothic.
- Post subheadings are now clickable with anchor links (`<a href="#id">`).
- Search now searches post body content (HTML stripped to plain text).
- **Search snippets**: search results show a context snippet (30 chars before/after the match).
- **Page jump input**: type a page number in the pagination bar and press Enter to jump straight to that page.

### Changed

- **Default fonts**: switched to system font stacks (`system-ui`, `-apple-system`, etc.) instead of bundled web fonts.
- **Navbar scaling**: larger navbar fonts and bigger icons — 28px social icons, 24px search/theme buttons.
- **CSS on-demand loading**: `dist/` now ships 10 separate CSS files under `dist/css/` rather than a single `arata.css`, so each page loads only the styles it needs.
- **CSS modular split**: source CSS reorganised into 10 modules under `src/css/` mirroring the runtime split.
- **CJK slugify**: replaced the ASCII allowlist with a punctuation denylist, so non-ASCII characters pass through into slugs.
- Sticky header navbar (position: sticky, always visible on scroll).
- Body font-weight increased to 600 for better readability.
- Theme toggle modernized: circular button with `var(--primary-color)` (#3555b3) background and white SVG icons.
- Default code font: `ui-monospace` system stack (no longer loads JetBrains Mono `@font-face`).
- Links page redesigned as cards with border, hover effect, and spacing.
- Search input auto-focuses when modal opens.
- Home page content updated with current features.
- Links page: card content no longer wrapped in `<a>` (`role=generic`); only the title is a link.
- Posts list: `post-header` changed from `<a>` to `<div>`; only the title is a link.
- Posts per page increased to 10 (was 7).
- Blockquote colour changed to `#BAC2DE` (was `#737373`).
- HR separator colour set to `#6c7086`.

### Fixed

- **RSS/static file routing**: `/atom.xml`, `/rss.xml`, and `/sitemap.xml` are now matched before the `[slug]` catch-all, so feeds and the sitemap are served correctly.
- **CJK heading IDs**: when a heading's slug is non-ASCII, a sequential fallback ID (`heading-1`, `heading-2`, …) is used so anchor links stay functional.
- **Links page layout**: `.link-item a` is now a flexbox row with proper avatar sizing and alignment.
- **Post page refresh**: no longer redirects to `/#/posts/<slug>`; `404.html` now uses a clean-path redirect so deep links load the right post.
- **ToC rendering**: `extract_toc_from_html` parsing bug fixed — heading IDs and titles are now extracted properly, so the ToC renders instead of being empty.
- **Cmd/Ctrl+K conflict**: `preventDefault` added so the shortcut no longer conflicts with the browser address bar's default Cmd/Ctrl+K behaviour.
- **Code font loading**: code font no longer loads JetBrains Mono via `@font-face`; defaults to the `ui-monospace` system stack.
- **Search scope**: search previously matched only title/description/tags; it now includes the post body too.

## [0.1.0] — 2025-06-22

The initial release of arata — a faithful reimplementation of the apollo blog theme using Gleam and Lustre.

### Added

- **Routing** (Phase 2): client-side routing via modem with 9 route variants (Home, Posts, Post, Projects, Talks, Tags, Tag, Page, NotFound) and paginated post index (`/posts/page/{n}`).
- **Design system** (Phase 1): the complete apollo visual design system ported from SCSS to plain CSS (2,135 lines) — colour palette, fonts, typography scale, 3-column layout, all component styles, syntax highlighting, 9 responsive breakpoints.
- **Post list** (Phase 5): paginated post list with Prev/Next pagination, draft labels, and active-nav highlighting.
- **Single post** (Phases 5-6): full article rendering with `.page-header` title, meta row (date, updated, word count, reading time), optional `tl;dr` box, body via `unsafe_raw_html`, tags, and a scroll-driven table of contents with IntersectionObserver active highlighting.
- **Projects** (Phase 7): column-balanced card grid with GitHub/Demo icon-buttons and `#tag` chips.
- **Talks** (Phase 7): responsive talk card grid with video thumbnails, play-button overlay, and meta row icon-buttons.
- **Taxonomy** (Phase 8): `/tags` index with post counts and `/tags/<tag>` single-tag pages.
- **Homepage** (Phase 9): custom landing page with hero section.
- **Standalone pages** (Phase 9): `/{slug}` pages (e.g. `/about`).
- **404** (Phase 9): apollo-style 404 page.
- **Theme system** (Phase 10): 3-state theme toggle (Light → Dark → Auto) with `localStorage` persistence and `matchMedia` reactivity.
- **Fancy code blocks** (Phase 11): copy-to-clipboard button and coloured language label on every `<pre><code>` block.
- **Search** (Phase 12): Cmd/Ctrl+K search modal with keyboard navigation (↑/↓ to navigate, Enter to follow, Esc to close).
- **Shortcodes** (Phase 13): note (static + dynamic), character, image, and mermaid shortcodes.
- **MathJax + Mermaid** (Phase 14): lazy-loaded MathJax typesetting and mermaid diagram rendering with theme-aware re-rendering.
- **SEO** (Phase 15): `<title>`, `<meta>` description, OpenGraph tags, Fediverse creator meta.
- **Feeds** (Phase 15): Atom 1.0 and RSS 2.0 feeds.
- **Sitemap** (Phase 15): `sitemap.xml` with all post + page URLs.
- **Analytics** (Phase 15): GoatCounter, Umami, and Google Analytics providers.
- **Comments** (Phase 15): Giscus and Utterances comment sections.
- **Wavy boundary** (Phase 16): a soft, SVG-based section divider (arata-original, not in apollo).
- **Build pipeline** (Phase 17): `gleam run -m build/pipeline` produces a complete static site in `dist/`.
- **Tests** (Phase 18): 57 unit tests covering routing, card reordering, tag index, search, and feed generation.
- **Accessibility** (Phase 18): `:focus-visible` styles for keyboard navigation.
- **Documentation** (Phase 19): configuration, content authoring, shortcode reference, and deployment guides.

### FFI modules

- `ffi/theme.ffi.mjs` — localStorage + matchMedia (theme toggle)
- `ffi/observer.ffi.mjs` — IntersectionObserver (TOC active highlighting)
- `ffi/codeblock.ffi.mjs` — code block enhancement (copy button + language label)
- `ffi/search.ffi.mjs` — global keydown listener (search shortcuts)
- `ffi/note.ffi.mjs` — note toggle (expand/collapse)
- `ffi/script.ffi.mjs` — MathJax + Mermaid loading and rendering
- `ffi/analytics.ffi.mjs` — analytics script injection

### Tech stack

- Gleam 1.14
- Lustre 5.7 (The Elm Architecture)
- modem 2.1 (client-side routing)
- gleam_json 3.1 (content index serialization)
- simplifile 2.4 (build pipeline file I/O)
- lustre_dev_tools 2.3 (dev server + bundling)
