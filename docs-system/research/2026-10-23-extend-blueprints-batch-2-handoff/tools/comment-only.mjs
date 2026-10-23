// Proves each changed code file differs from base only in comments.
import { execFileSync } from 'node:child_process';
import { createRequire } from 'node:module';
const req = createRequire(process.cwd() + '/package.json');
const esbuild = req('esbuild');
const svm = await import(req.resolve('svelte/compiler')); const compile = svm.compile ?? svm.default.compile;
const files = execFileSync('git', ['diff', '--name-only', 'origin/main'], { encoding: 'utf8' }).trim().split('\n');
const show = (rev, f) => { try { return execFileSync('git', ['show', `${rev}:${f}`], { encoding: 'utf8', maxBuffer: 1e8 }); } catch { return null; } };
const stripBlock = (s) => s.replace(/\/\*[\s\S]*?\*\//g, '');
const norm = (s) => s.replace(/\s+/g, ' ').trim();
let bad = 0, n = 0, skipped = [];
for (const f of files) {
  const ext = f.split('.').pop();
  if (['md', 'json', 'yaml', 'yml', 'txt'].includes(ext)) continue;
  const a = show('origin/main', f), b = show('HEAD', f);
  if (a == null || b == null) { skipped.push(f + ' (added/removed)'); continue; }
  let A, B;
  try {
    if (['ts', 'js', 'mjs', 'cjs'].includes(ext)) {
      const t = (s) => esbuild.transformSync(s, { loader: ext === 'ts' ? 'ts' : 'js', legalComments: 'none', minifyWhitespace: true }).code;
      A = t(a); B = t(b);
    } else if (ext === 'svelte') {
      const strip = (s) => s.replace(/<!--[\s\S]*?-->/g, '');
      const t = (s) => { const r = compile(strip(s), { generate: 'server', filename: f }); return r.js.code.replace(/\/\*[\s\S]*?\*\/|\/\/[^\n]*/g, '') + stripBlock(r.css?.code ?? ''); };
      A = norm(t(a)).replace(/svelte-[a-z0-9]+/g,'svelte-H'); B = norm(t(b)).replace(/svelte-[a-z0-9]+/g,'svelte-H');
    } else if (ext === 'css' || ext === 'sql' || ext === 'jsonc') {
      const t = (s) => norm(stripBlock(s).replace(ext === 'sql' ? /--[^\n]*/g : /(^|[^:])\/\/[^\n]*/g, '$1'));
      A = t(a); B = t(b);
    } else { skipped.push(f); continue; }
  } catch (e) { skipped.push(f + ' (' + e.message.split('\n')[0].slice(0, 60) + ')'); continue; }
  n++;
  if (A !== B) { bad++; console.log('CODE DIFFERS:', f); }
}
console.log(`checked ${n}, code differs in ${bad}`);
if (skipped.length) console.log('skipped:', skipped.join(', '));
