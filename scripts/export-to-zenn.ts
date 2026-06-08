import { unified } from "npm:unified@11";
import uniorgParse from "npm:uniorg-parse@2";
import uniorgRehype from "npm:uniorg-rehype@1";
import rehypeRemark from "npm:rehype-remark@10";
import remarkGfm from "npm:remark-gfm@4";
import remarkStringify from "npm:remark-stringify@3";
import { parse as parseYaml, stringify as stringifyYaml } from "npm:yaml@2";
import { basename, extname, join } from "jsr:@std/path@1";

interface SourceMeta {
  title?: string;
  date?: string;
  tags?: string;
  emoji?: string;
  type?: string;
}

interface ZennMeta {
  title: string;
  emoji: string;
  type: string;
  topics: string[];
  published: boolean;
  published_at: string;
}

function parseOrgDate(raw: string): string {
  const m = raw.match(/\[(\d{4}-\d{2}-\d{2})(?:\s+\w+)?(?:\s+(\d{2}:\d{2}))?\]/);
  if (!m) return "";
  const date = m[1];
  const time = m[2] ?? "00:00";
  return `${date} ${time}`;
}

function parseOrgTags(raw: string): string[] {
  return raw.split(":").map((t) => t.trim()).filter(Boolean);
}

function parseMdTags(raw: string): string[] {
  if (raw.includes(",")) {
    return raw.split(",").map((t) => t.trim()).filter(Boolean);
  }
  return raw.split(/\s+/).map((t) => t.trim()).filter(Boolean);
}

function parseOrgMetadata(content: string): SourceMeta {
  const meta: SourceMeta = {};
  for (const line of content.split("\n")) {
    const m = line.match(/^#\+(\w+):\s*(.*)/);
    if (!m) continue;
    const [, key, value] = m;
    switch (key.toUpperCase()) {
      case "TITLE": meta.title = value.trim(); break;
      case "DATE": meta.date = parseOrgDate(value.trim()); break;
      case "TAGS": meta.tags = value.trim(); break;
      case "EMOJI": meta.emoji = value.trim(); break;
      case "TYPE": meta.type = value.trim(); break;
    }
  }
  return meta;
}

function parseMdFrontmatter(content: string): { meta: SourceMeta; body: string } {
  const match = content.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)/);
  if (!match) return { meta: {}, body: content };
  const raw = parseYaml(match[1]) as Record<string, unknown>;
  const body = match[2] ?? "";
  const meta: SourceMeta = {};
  if (typeof raw.title === "string") meta.title = raw.title;
  if (typeof raw.emoji === "string") meta.emoji = raw.emoji;
  if (typeof raw.type === "string") meta.type = raw.type;
  if (typeof raw.tags === "string") meta.tags = raw.tags;
  const dateField = raw.date ?? raw.publishDate;
  if (typeof dateField === "string") {
    meta.date = parseOrgDate(dateField);
  }
  return { meta, body };
}

function toZennFrontmatter(meta: SourceMeta): ZennMeta {
  let topics: string[] = [];
  if (meta.tags) {
    const raw = meta.tags;
    topics = raw.startsWith(":") ? parseOrgTags(raw) : parseMdTags(raw);
    topics = topics.slice(0, 5);
  }
  return {
    title: meta.title ?? "Untitled",
    emoji: meta.emoji ?? "📝",
    type: meta.type ?? "tech",
    topics,
    published: true,
    published_at: meta.date ?? "",
  };
}

async function convertOrgToMarkdown(content: string): Promise<string> {
  const processor = unified()
    .use(uniorgParse)
    .use(uniorgRehype)
    .use(rehypeRemark)
    .use(remarkGfm)
    .use(remarkStringify);
  const result = await processor.process(content);
  return String(result);
}

function trimDateFromFilename(filename: string): string {
  const ext = extname(filename);
  const base = basename(filename, ext);
  // Strip YYYY-MM-DD- prefix if followed by additional slug
  const m = base.match(/^\d{4}-\d{2}-\d{2}-(.+)/);
  return m ? `${m[1]}.md` : `${base}.md`;
}

function renderFrontmatter(zenn: ZennMeta): string {
  const obj: Record<string, unknown> = {
    title: zenn.title,
    emoji: zenn.emoji,
    type: zenn.type,
    topics: zenn.topics,
    published: zenn.published,
  };
  if (zenn.published_at) obj.published_at = zenn.published_at;
  return `---\n${stringifyYaml(obj, { lineWidth: 0 }).trimEnd()}\n---\n`;
}

async function processFile(
  filepath: string,
  outDir: string,
): Promise<void> {
  const content = await Deno.readTextFile(filepath);
  const filename = basename(filepath);
  const ext = extname(filename).toLowerCase();
  const outName = trimDateFromFilename(filename);
  const outPath = join(outDir, outName);

  let meta: SourceMeta;
  let body: string;

  if (ext === ".org") {
    meta = parseOrgMetadata(content);
    body = await convertOrgToMarkdown(content);
  } else {
    const parsed = parseMdFrontmatter(content);
    meta = parsed.meta;
    body = parsed.body;
  }

  const zenn = toZennFrontmatter(meta);
  const output = renderFrontmatter(zenn) + "\n" + body.trimStart();
  await Deno.writeTextFile(outPath, output);
  console.log(`  ${filename} → ${outName}`);
}

async function main() {
  const postsDir = join(Deno.cwd(), "posts");
  const outDir = join(Deno.cwd(), "zenn-articles");

  await Deno.mkdir(outDir, { recursive: true });

  const files: string[] = [];
  for await (const entry of Deno.readDir(postsDir)) {
    if (!entry.isFile) continue;
    const ext = extname(entry.name).toLowerCase();
    if (ext === ".org" || ext === ".md") {
      files.push(join(postsDir, entry.name));
    }
  }
  files.sort();

  console.log(`Converting ${files.length} posts → ${outDir}`);
  let ok = 0;
  let fail = 0;
  for (const f of files) {
    try {
      await processFile(f, outDir);
      ok++;
    } catch (err) {
      console.error(`  ERROR: ${basename(f)}: ${err}`);
      fail++;
    }
  }
  console.log(`Done: ${ok} converted, ${fail} failed.`);
}

await main();
