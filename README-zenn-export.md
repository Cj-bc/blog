# Zenn Markdown Exporter

This tool exports blog posts from the `posts/` directory to Zenn-flavored markdown format.

## Features

- Converts both `.org` and `.md` files to Zenn-flavored markdown
- Extracts metadata from org-mode format and converts to YAML front matter
- Removes date prefixes from filenames (e.g., `2020-08-02-title.org` → `title.md`)
- Generates Zenn-compatible front matter with:
  - `title`: Post title
  - `emoji`: Emoji icon (defaults to "📝")
  - `type`: Article type (defaults to "tech")
  - `topics`: Tags/topics (converted from org-mode tags)
  - `published`: Always set to `true`
  - `published_at`: Publication date in `YYYY-MM-DD hh:mm` format

## Usage

### Node.js/TypeScript Version

```bash
npm install
npm run zenn-export
```

This will:
1. Read all `.org` and `.md` files from `posts/` directory
2. Convert them to Zenn-flavored markdown
3. Save the converted files to `zenn-articles/` directory

### Haskell Version

The repository also includes a Haskell implementation using Pandoc:

```bash
stack build
stack exec zenn-export
```

**Note:** The Haskell version requires Stack or Cabal to be installed.

## Output

Converted files are saved to the `zenn-articles/` directory with:
- Date prefixes removed from filenames
- Zenn YAML front matter
- Markdown-formatted content

## Example

Input file: `posts/2020-08-02-helloHakylly.org`

```org
#+TITLE: Blog作った！！
#+DATE: [2020-08-02 Sun]
#+TAGS: :info:
#+AUTHOR: Cj-bc

* Blog作った！！
...
```

Output file: `zenn-articles/helloHakylly.md`

```markdown
---
title: Blog作った！！
emoji: 📝
type: tech
topics:
  - info
published: true
published_at: 2020-08-02 00:00
---

# Blog作った！！
...
```

## Implementation Details

The Node.js version uses:
- `glob` for file pattern matching
- `yaml` for YAML front matter generation
- Custom org-mode to markdown converter

The Haskell version uses:
- `pandoc` for document conversion
- `pandoc-types` for AST manipulation
- Custom metadata extraction and transformation
