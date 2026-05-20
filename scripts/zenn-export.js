#!/usr/bin/env node

import { readFile, writeFile, mkdir } from 'fs/promises';
import { existsSync } from 'fs';
import { join, basename, extname, dirname } from 'path';
import { fileURLToPath } from 'url';
import { glob } from 'glob';
import YAML from 'yaml';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * Extract metadata from content (both org-mode and YAML front matter)
 */
function extractMetadata(content) {
  const lines = content.split('\n');

  // Check if content starts with YAML front matter (---)
  if (lines[0].trim() === '---') {
    return extractYAMLMetadata(content);
  } else {
    return extractOrgMetadata(content);
  }
}

/**
 * Extract YAML front matter from markdown
 */
function extractYAMLMetadata(content) {
  const lines = content.split('\n');
  let inFrontMatter = false;
  let frontMatterLines = [];
  let contentStart = 0;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();

    if (i === 0 && line === '---') {
      inFrontMatter = true;
      continue;
    }

    if (inFrontMatter && line === '---') {
      contentStart = i + 1;
      break;
    }

    if (inFrontMatter) {
      frontMatterLines.push(lines[i]);
    }
  }

  // Parse YAML-like metadata (simple key: value format)
  const metadata = {};
  for (const line of frontMatterLines) {
    const match = line.match(/^(\w+):\s*(.+)$/);
    if (match) {
      const [, key, value] = match;
      metadata[key.toLowerCase()] = value.trim();
    }
  }

  const bodyContent = lines.slice(contentStart).join('\n').trim();
  return { metadata, bodyContent };
}

/**
 * Extract org-mode metadata from content
 */
function extractOrgMetadata(content) {
  const lines = content.split('\n');
  const metadata = {};
  let contentStart = 0;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();

    // Check for org-mode metadata lines
    if (line.startsWith('#+')) {
      const match = line.match(/^#\+(\w+):\s*(.+)$/i);
      if (match) {
        const [, key, value] = match;
        metadata[key.toLowerCase()] = value.trim();
        contentStart = i + 1;
      }
    } else if (line && !line.startsWith('#')) {
      // First non-comment, non-empty line marks the start of content
      break;
    }
  }

  const bodyContent = lines.slice(contentStart).join('\n').trim();
  return { metadata, bodyContent };
}

/**
 * Convert tags format to array
 * Input: ":tag1:tag2:tag3:" or "tag1,tag2,tag3" -> Output: ["tag1", "tag2", "tag3"]
 */
function parseTags(tagsStr) {
  if (!tagsStr) return [];

  // Handle org-mode format (:tag1:tag2:)
  if (tagsStr.includes(':')) {
    return tagsStr
      .split(':')
      .map(t => t.trim())
      .filter(t => t.length > 0);
  }

  // Handle comma-separated format (tag1,tag2,tag3)
  return tagsStr
    .split(',')
    .map(t => t.trim())
    .filter(t => t.length > 0);
}

/**
 * Parse date format (org-mode or standard)
 * Input: "[2020-08-02 Sun]", "[2020-08-02 Sun 14:30]", or "\"2020-08-02 11:16\""
 * Output: "2020-08-02 14:30" or "2020-08-02 00:00"
 */
function parseOrgDate(dateStr) {
  if (!dateStr) return null;

  // Remove brackets, quotes, and extract date components
  const cleaned = dateStr.replace(/[\[\]"]/g, '').trim();
  const parts = cleaned.split(/\s+/);

  if (parts.length === 0) return null;

  const datePart = parts[0]; // YYYY-MM-DD
  const timePart = parts.length >= 2 ? parts[parts.length - 1] : '00:00';

  // Check if timePart looks like a time (HH:MM)
  if (timePart.match(/^\d{1,2}:\d{2}$/)) {
    return `${datePart} ${timePart}`;
  }

  return `${datePart} 00:00`;
}

/**
 * Convert org-mode content to markdown (basic conversion)
 */
function convertOrgToMarkdown(orgContent) {
  let markdown = orgContent;

  // Convert org headers (* Header) to markdown (# Header)
  // This handles multiple levels
  markdown = markdown.replace(/^(\*+)\s+(.+)$/gm, (match, stars, content) => {
    const level = stars.length;
    return '#'.repeat(level) + ' ' + content;
  });

  // Convert org code blocks to markdown code blocks
  markdown = markdown.replace(/^#\+begin_src\s+(\w+)\s*$/gmi, (match, lang) => {
    return '```' + lang;
  });
  markdown = markdown.replace(/^#\+end_src\s*$/gmi, '```');

  // Convert org example blocks
  markdown = markdown.replace(/^#\+begin_example\s*$/gmi, '```');
  markdown = markdown.replace(/^#\+end_example\s*$/gmi, '```');

  // Convert org bold **text** to markdown **text** (already the same)
  // Convert org italic /text/ to markdown *text*
  // But be careful not to match slashes in URLs (https://...)
  markdown = markdown.replace(/([^:])\/([^\/\s]+)\//g, '$1*$2*');

  // Convert org code =text= and ~text~ to markdown `text`
  markdown = markdown.replace(/=([^=\n]+)=/g, '`$1`');
  markdown = markdown.replace(/~([^~\n]+)~/g, '`$1`');

  // Convert org links [[url][text]] to markdown [text](url)
  markdown = markdown.replace(/\[\[([^\]]+)\]\[([^\]]+)\]\]/g, '[$2]($1)');

  // Convert org links [[url]] to markdown [url](url)
  markdown = markdown.replace(/\[\[([^\]]+)\]\]/g, '[$1]($1)');

  // Convert org-mode PROPERTIES drawer (remove it as it's not needed in markdown)
  markdown = markdown.replace(/^\s*:PROPERTIES:[\s\S]*?:END:\s*$/gm, '');

  // Remove remaining org directives that we don't need
  markdown = markdown.replace(/^#\+\w+:.*$/gm, '');

  return markdown.trim();
}

/**
 * Generate Zenn front matter from metadata
 */
function generateZennFrontMatter(metadata) {
  const title = metadata.title || 'Untitled';
  const emoji = metadata.emoji || '📝';
  const type = metadata.type || 'tech';
  const tags = parseTags(metadata.tags || '');
  const published = true;

  // Try different date fields
  const dateField = metadata.date || metadata.publishdate || metadata.publishDate;
  const publishedAt = parseOrgDate(dateField);

  const frontMatter = {
    title,
    emoji,
    type,
    topics: tags,
    published,
  };

  if (publishedAt) {
    frontMatter.published_at = publishedAt;
  }

  return '---\n' + YAML.stringify(frontMatter) + '---\n\n';
}

/**
 * Remove date prefix from filename
 * Input: "2020-08-02-title.org" -> Output: "title.md"
 */
function removeDatePrefix(filename) {
  const base = basename(filename, extname(filename));

  // Match pattern: YYYY-MM-DD-restofname
  const match = base.match(/^(\d{4})-(\d{2})-(\d{2})-(.+)$/);

  if (match) {
    return match[4] + '.md';
  }

  return base + '.md';
}

/**
 * Process a single file
 */
async function processFile(inputPath, outputDir) {
  console.log(`Processing: ${inputPath}`);

  try {
    const content = await readFile(inputPath, 'utf-8');
    const ext = extname(inputPath).toLowerCase();

    let markdown, zennMeta;

    if (ext === '.org') {
      // Process org-mode file
      const { metadata, bodyContent } = extractMetadata(content);
      const frontMatter = generateZennFrontMatter(metadata);
      const markdownBody = convertOrgToMarkdown(bodyContent);
      markdown = frontMatter + markdownBody;
    } else if (ext === '.md') {
      // Process markdown file - extract any existing front matter and convert
      const { metadata, bodyContent } = extractMetadata(content);
      const frontMatter = generateZennFrontMatter(metadata);
      markdown = frontMatter + bodyContent;
    } else {
      console.log(`  ⚠ Skipping unsupported file type: ${ext}`);
      return;
    }

    // Generate output filename
    const outputFilename = removeDatePrefix(inputPath);
    const outputPath = join(outputDir, outputFilename);

    // Write the output
    await writeFile(outputPath, markdown, 'utf-8');
    console.log(`  ✓ Exported to: ${outputPath}`);
  } catch (error) {
    console.error(`  ✗ Error processing ${inputPath}:`, error.message);
  }
}

/**
 * Main function
 */
async function main() {
  const postsDir = 'posts';
  const outputDir = 'zenn-articles';

  // Check if posts directory exists
  if (!existsSync(postsDir)) {
    console.error(`Error: posts directory not found: ${postsDir}`);
    process.exit(1);
  }

  // Create output directory if it doesn't exist
  if (!existsSync(outputDir)) {
    await mkdir(outputDir, { recursive: true });
  }

  // Find all org and md files
  const orgFiles = await glob(`${postsDir}/*.org`);
  const mdFiles = await glob(`${postsDir}/*.md`);
  const allFiles = [...orgFiles, ...mdFiles];

  console.log(`Found ${allFiles.length} files to convert\n`);

  // Process each file
  for (const file of allFiles) {
    await processFile(file, outputDir);
  }

  console.log(`\nExport complete! Files saved to: ${outputDir}`);
}

main().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
