import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { marked } from 'marked';
import type { Doc, Kind, Option, PullRequest, Segment } from '#lib/types';

const DIR = join(process.cwd(), 'content');

const critic = (s: string) =>
	s.replace(/\{--(.+?)--\}/gs, '<del>$1</del>').replace(/\{\+\+(.+?)\+\+\}/gs, '<ins>$1</ins>');
const plain = (html: string) =>
	html
		.replace(/<del>.*?<\/del>\s*/gs, '')
		.replace(/<[^>]+>/g, '')
		.replace(/&amp;/g, '&')
		.replace(/&quot;/g, '"')
		.replace(/&#39;/g, "'")
		.replace(/&lt;/g, '<')
		.replace(/&gt;/g, '>')
		.trim();
const inline = (s: string) => marked.parseInline(critic(s), { async: false });
// A table scrolls inside its own frame on a narrow page, so the page itself never scrolls sideways.
const block = (s: string) =>
	(marked.parse(critic(s), { async: false }) as string)
		.replaceAll('<table>', '<div class="table-frame" tabindex="0" role="group" aria-label="Table"><table>')
		.replaceAll('</table>', '</table></div>');

function frontMatter(raw: string): { meta: Record<string, string>; prs: string[]; body: string } {
	const m = /^---\n(.*?)\n---\n(.*)$/s.exec(raw);
	if (!m) throw new Error('A document starts with a header between two --- lines.');
	const meta: Record<string, string> = {};
	const prs: string[] = [];
	for (const line of m[1].split('\n')) {
		const item = /^\s+-\s+(.*)$/.exec(line);
		if (item) prs.push(item[1]);
		else {
			const kv = /^(\w+):\s*(.*)$/.exec(line);
			if (kv) meta[kv[1]] = kv[2];
		}
	}
	return { meta, prs, body: m[2] };
}

function parse(id: string, raw: string): Doc {
	const { meta, prs, body } = frontMatter(raw);
	const lines = body.split('\n');
	const titleAt = lines.findIndex((l) => l.startsWith('# '));
	const titleHtml = inline(lines[titleAt].slice(2));
	lines.splice(0, titleAt + 1);

	const segments: Segment[] = [];
	let buf: string[] = [];
	const flush = () => {
		const text = buf.join('\n').trim();
		if (text) segments.push({ type: 'html', html: block(text) });
		buf = [];
	};
	let q = 0;
	for (let i = 0; i < lines.length; i++) {
		const open = /^:::question\s+(.*)$/.exec(lines[i]);
		if (open) {
			flush();
			const options: Option[] = [];
			for (i++; lines[i] !== ':::'; i++) {
				const o = /^-\s+(.*?)(\s*\{recommended\})?$/.exec(lines[i]);
				if (!o) continue;
				const html = inline(o[1]);
				const bold = /<strong>(.*?)<\/strong>/s.exec(html);
				options.push({ html, label: plain(bold ? bold[1] : html).replace(/\.$/, ''), recommended: !!o[2] });
			}
			segments.push({ type: 'question', id: `q${++q}`, name: open[1], options });
		} else if (lines[i] === ':::decide') {
			flush();
			segments.push({ type: 'decide' });
		} else buf.push(lines[i]);
	}
	flush();
	const kind = meta.kind as Kind;
	if (!segments.some((s) => s.type === 'decide')) segments.push({ type: 'decide' });

	const first = segments.find((s) => s.type === 'html');
	const para = first && first.type === 'html' ? /<p>(.*?)<\/p>/s.exec(first.html) : null;
	return {
		id,
		kind,
		repo: meta.repo,
		sent: meta.sent,
		returned: meta.returned,
		prs: prs.map((p): PullRequest => {
			const [n, name] = p.split('|').map((x) => x.trim());
			return { number: Number(n), name, url: `https://github.com/${meta.repo}/pull/${n}/files` };
		}),
		approve: inline(meta.approve ?? ''),
		sendback: inline(meta.sendback ?? ''),
		mock: meta.mock ?? '',
		titleHtml,
		title: plain(titleHtml),
		summary: para ? plain(para[1]) : '',
		segments,
		questions: q,
		changes: (raw.match(/\{\+\+/g) ?? []).length
	};
}

export function allDocs(): Doc[] {
	return readdirSync(DIR)
		.filter((f) => f.endsWith('.md'))
		.sort()
		.map((f) => parse(f.replace(/\.md$/, ''), readFileSync(join(DIR, f), 'utf8')));
}

export function oneDoc(id: string): Doc | undefined {
	return allDocs().find((d) => d.id === id);
}

export interface MergedGroup {
	tool: string;
	repo: string;
	lines: { pr: number; time: string; html: string }[];
}

export function merged(): MergedGroup[] {
	const groups = JSON.parse(readFileSync(join(DIR, 'merged.json'), 'utf8')) as {
		tool: string;
		repo: string;
		lines: { pr: number; time: string; text: string }[];
	}[];
	return groups.map((g) => ({
		...g,
		lines: g.lines.map((l) => ({ pr: l.pr, time: l.time, html: inline(l.text) }))
	}));
}
