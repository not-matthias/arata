//// Homepage view with optional aratafetch block.

import data/page.{type Page}
import gleam/option
import lustre/attribute
import lustre/element.{type Element, none, unsafe_raw_html}
import lustre/element/html

/// Render the homepage.
///
/// aratafetch is rendered AFTER the markdown body when enabled.
pub fn view(
  home: Page,
  aratafetch_enabled: Bool,
  aratafetch_view: Element(msg),
) -> Element(msg) {
  html.main([], [
    html.article([], [
      html.section([attribute.class("body")], [
        html.div([attribute.class("page-header")], [
          html.text(home.title),
          ..view_subtitle(home.subtitle)
        ]),

        // Markdown body
        unsafe_raw_html("", "div", [], home.body),

        //  aratafetch
        view_aratafetch(aratafetch_enabled, aratafetch_view),
      ]),
    ]),
  ])
}

/// Conditionally render aratafetch.
///
/// Invariant:
///   - disabled → renders nothing (layout identical to pre-feature)
fn view_aratafetch(
  enabled: Bool,
  aratafetch_view: Element(msg),
) -> Element(msg) {
  case enabled {
    True -> aratafetch_view
    False -> none()
  }
}

fn view_subtitle(subtitle: option.Option(String)) -> List(Element(msg)) {
  case subtitle {
    option.Some(text) -> [
      html.br([]),
      html.small([], [html.text(text)]),
    ]
    option.None -> []
  }
}
