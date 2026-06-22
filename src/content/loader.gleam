//// Content loader: reads `.md` files from `content/posts/` and `content/pages/`
//// at startup, parses TOML frontmatter (`+++ ... +++`), and renders the
//// markdown body via mork. This replaces the hardcoded content in
//// `sample_content.gleam` with a Zola-like file-based content model.
////
//// Frontmatter format (TOML, between `+++` delimiters):
////   +++
////   title = "Post Title"
////   date = "2025-01-15"
////   updated = "2025-01-20"  # optional
////   description = "Short description"
////   tags = ["tag1", "tag2"]  # optional
////   draft = false  # optional, defaults to false
////   tldr = "One-line summary"  # optional
////   +++
////
//// The rest of the file is markdown, parsed by mork at load time.

import data/markdown
import data/page.{type Page, Page}
import data/post.{type Post, type TocEntry, Post, TocEntry}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile
import tom

/// Load all posts from `content/posts/`. Each `.md` file becomes a `Post`.
/// Posts are sorted by date descending (newest first).
pub fn load_posts() -> List(Post) {
  let dir = "content/posts"
  case simplifile.read_directory(at: dir) {
    Ok(filenames) ->
      filenames
      |> list.filter(fn(name) { string.ends_with(name, ".md") })
      |> list.map(fn(name) { load_post(dir <> "/" <> name, name) })
      |> list.filter_map(fn(r) { r })
      |> list.sort(by: fn(a, b) { string.compare(b.date, a.date) })
    Error(_) -> []
  }
}

/// Load all pages from `content/pages/`. Each `.md` file becomes a `Page`.
pub fn load_pages() -> List(Page) {
  let dir = "content/pages"
  case simplifile.read_directory(at: dir) {
    Ok(filenames) ->
      filenames
      |> list.filter(fn(name) { string.ends_with(name, ".md") })
      |> list.map(fn(name) { load_page(dir <> "/" <> name, name) })
      |> list.filter_map(fn(r) { r })
    Error(_) -> []
  }
}

/// Load the homepage from `content/pages/home.md`.
pub fn load_homepage() -> Page {
  let path = "content/pages/home.md"
  case load_page(path, "home.md") {
    Ok(page) -> page
    Error(_) -> Page(slug: "home", title: "arata", body: "", subtitle: None)
  }
}

/// Load a single post from a file path.
fn load_post(path: String, filename: String) -> Result(Post, Nil) {
  use content <- result.try(
    simplifile.read(from: path) |> result.replace_error(Nil),
  )
  let #(frontmatter, body) = split_frontmatter(content)
  use toml <- result.try(tom.parse(frontmatter) |> result.replace_error(Nil))

  let slug = string.replace(filename, ".md", "")
  let title = tom.get_string(toml, ["title"]) |> result.unwrap(slug)
  let date = tom.get_string(toml, ["date"]) |> result.unwrap("")
  let updated = case tom.get_string(toml, ["updated"]) {
    Ok(d) -> Some(d)
    Error(_) -> None
  }
  let description = tom.get_string(toml, ["description"]) |> result.unwrap("")
  let tags = case tom.get_array(toml, ["tags"]) {
    Ok(arr) ->
      arr
      |> list.map(fn(item) {
        case tom.as_string(item) {
          Ok(s) -> s
          Error(_) -> ""
        }
      })
      |> list.filter(fn(s) { s != "" })
    Error(_) -> []
  }
  let draft = case tom.get_bool(toml, ["draft"]) {
    Ok(b) -> b
    Error(_) -> False
  }
  let tldr = case tom.get_string(toml, ["tldr"]) {
    Ok(t) -> Some(t)
    Error(_) -> None
  }
  let html_body = markdown.to_html(body)
  let toc = extract_toc(body)
  let word_count = count_words(body)
  let reading_time = case word_count {
    0 -> 0
    n -> int.max(1, n / 200)
  }

  Ok(Post(
    slug: slug,
    title: title,
    date: date,
    updated: updated,
    description: description,
    body: html_body,
    toc: toc,
    tags: tags,
    draft: draft,
    tldr: tldr,
    word_count: word_count,
    reading_time: reading_time,
  ))
}

/// Load a single page from a file path.
fn load_page(path: String, filename: String) -> Result(Page, Nil) {
  use content <- result.try(
    simplifile.read(from: path) |> result.replace_error(Nil),
  )
  let #(frontmatter, body) = split_frontmatter(content)
  use toml <- result.try(tom.parse(frontmatter) |> result.replace_error(Nil))

  let slug = string.replace(filename, ".md", "")
  let title = tom.get_string(toml, ["title"]) |> result.unwrap(slug)
  let subtitle = case tom.get_string(toml, ["subtitle"]) {
    Ok(s) -> Some(s)
    Error(_) -> None
  }
  let html_body = markdown.to_html(body)

  Ok(Page(slug: slug, title: title, body: html_body, subtitle: subtitle))
}

/// Split a markdown file into frontmatter and body. The frontmatter is
/// between `+++` delimiters (Zola-style TOML). If there's no frontmatter,
/// returns an empty string for the frontmatter and the full content as body.
fn split_frontmatter(content: String) -> #(String, String) {
  case string.split_once(content, "+++\n") {
    Error(_) -> #("", content)
    Ok(#(_, rest)) ->
      case string.split_once(rest, "+++\n") {
        Error(_) -> #("", content)
        Ok(#(frontmatter, body)) -> #(frontmatter, body)
      }
  }
}

/// Extract a simple table of contents from the markdown body: one TocEntry
/// per `## ` (h2) heading. The id is derived from the heading text
/// (lowercased, spaces replaced with hyphens).
fn extract_toc(markdown: String) -> List(TocEntry) {
  markdown
  |> string.split("\n")
  |> list.filter(fn(line) { string.starts_with(line, "## ") })
  |> list.map(fn(line) {
    let title = string.replace(line, "## ", "")
    let id = slugify(title)
    TocEntry(id: id, title: title, children: [])
  })
}

/// Convert a heading title to a URL-safe slug.
fn slugify(text: String) -> String {
  text
  |> string.lowercase()
  |> string.replace(" ", "-")
  |> string.replace("'", "")
  |> string.replace(".", "")
  |> string.replace(",", "")
  |> string.replace(":", "")
  |> string.replace("?", "")
  |> string.replace("!", "")
  |> string.replace("(", "")
  |> string.replace(")", "")
}

/// Count words in a markdown string (rough estimate).
fn count_words(markdown: String) -> Int {
  markdown
  |> string.split("\n")
  |> list.filter(fn(line) { !string.starts_with(line, "```") })
  |> string.join("\n")
  |> string.split(" ")
  |> list.length()
}
