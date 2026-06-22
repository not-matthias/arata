+++
title = "arata"
subtitle = "A modern and minimalistic blog theme powered by Gleam and Lustre."
+++

## Features

- Light, dark, and auto themes
- [Projects page](/projects)
- [Talks page](/talks)
- MathJax rendering
- [Taxonomies](/tags)
- Custom homepage
- Comments
- Search functionality

## Quick Start

1. **Scaffold the project:**

```shell
gleam new my-blog --template javascript
cd my-blog
gleam add lustre modem
```

2. **Start the dev server:**

```shell
gleam run -m lustre/dev start
```

3. **Write content** as markdown (parsed by mork).

Checkout all the [options you can configure](/posts/configuration) and the [example posts](/posts).
