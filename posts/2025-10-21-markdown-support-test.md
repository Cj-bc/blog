---
title: Testing Markdown Support
tags:
  - info
  - markdown
  - test
date: October 21, 2025
author: Cj-bc
kind: Memo
status: Normal
---

# Markdown Support Added!

This is a test post written in **Markdown format** to verify that the blog now supports both Org mode and Markdown files.

## Features

- Standard Markdown syntax
- YAML frontmatter for metadata
- Code blocks with syntax highlighting
- Lists and formatting

## Code Example

Here's a simple code example:

```javascript
function greet(name) {
  console.log(`Hello, ${name}!`);
}

greet("World");
```

## Why Markdown Support?

Markdown is a widely-used format that:

1. Has excellent editor support
2. Is easy to write and read
3. Integrates well with many tools
4. Complements the existing Org mode support

## Conclusion

With this update, you can now write blog posts in either:

- **Org mode** (.org files) - with custom metadata headers
- **Markdown** (.md files) - with YAML frontmatter

Both formats will be processed through the same Pandoc pipeline and built into the final site using Astro.
