import { chromium } from '/var/home/glw907/Projects/cairn-cms/node_modules/playwright/index.mjs';
// tokens.css: an unlayered mode token (--x), light on :root, dark under system pref and explicit.
const tokens = `:root{--x:base-light}
@media (prefers-color-scheme: dark){:root:not([data-theme]){--x:base-dark}}
:root[data-theme="t-dark"]{--x:base-dark}`;
const option = (light, dark) => `${light}{--x:opt-light}
@media (prefers-color-scheme: dark){:root:not([data-theme]){--x:opt-dark}}
${dark}{--x:opt-dark}`;
const lightSel = { fix: [':root,:root:has(input.theme-controller[value="t"]:checked),:root[data-theme="t"]', ':root:has(input.theme-controller[value="t-dark"]:checked),:root[data-theme="t-dark"]'] };
const b = await chromium.launch();
for (const [k, sel] of Object.entries(lightSel)) for (const scheme of ['light', 'dark']) for (const dt of [null, 't', 't-dark']) {
  const ctx = await b.newContext({ colorScheme: scheme }); const p = await ctx.newPage();
  await p.setContent(`<html ${dt ? `data-theme="${dt}"` : ''}><head><style>${tokens}</style><style>${option(...sel)}</style></head><body></body></html>`);
  const v = await p.evaluate(() => getComputedStyle(document.documentElement).getPropertyValue('--x').trim());
  const want = dt === 't' ? 'opt-light' : dt === 't-dark' ? 'opt-dark' : scheme === 'dark' ? 'opt-dark' : 'opt-light';
  console.log(k.padEnd(5), 'system', scheme.padEnd(5), 'cookie', String(dt).padEnd(6), '->', v.padEnd(10), v === want ? 'ok' : 'WRONG');
  await ctx.close();
}
await b.close();
