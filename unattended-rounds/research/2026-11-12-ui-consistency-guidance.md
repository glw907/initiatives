# Published guidance on consistent UI from unattended agent runs

Collected 2026-11-12 by a read-only research subagent (web search and fetch). The quotes are as
the fetch tool returned them. A row marked "snippet" was seen only in a search result and wasn't
opened. Nothing here is a measured result unless the row says so.

The question: when Claude Code builds UI across long unattended runs, what keeps a new page from
getting its own layout and its own interaction pattern?

## What Anthropic publishes

| Source | What it says |
| --- | --- |
| [Best practices](https://code.claude.com/docs/en/best-practices) | Give a visual target: "paste the screenshot of the design or the error into the prompt". Name a pattern to follow: "follow the pattern in HotDogWidget.php and build a calendar widget". Verify with "A browser screenshot next to the mockup". Ask for evidence: "For a session you weren't watching, it's also the only evidence you have". A fresh reviewer "isn't swayed by the reasoning that produced the code". `/verify` "catches the kind of problem that tests and typechecks miss". |
| [Skills](https://code.claude.com/docs/en/skills) | A skill's `paths` field: "Claude loads the skill automatically only when working with files matching the patterns". `/verify` "writes what worked to `.claude/skills/verify/SKILL.md` ... so later runs and other agents follow the same steps". |
| [Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps), 2026-03-24 | A separate evaluator scores four criteria: design quality ("a coherent whole rather than a collection of parts"), originality, craft ("typography hierarchy, spacing consistency, color harmony, contrast ratios"), and functionality. "I gave the evaluator the Playwright MCP, which let it interact with the live page directly before scoring each criterion." It was calibrated "using few-shot examples with detailed score breakdowns". The planner wrote "a visual design language for the app as part of the spec". The full harness "was over 20x more expensive", and "For tasks within that boundary, the evaluator became unnecessary overhead". |
| [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents), 2025-11-26 | "each new session begins with no memory of what came before". State carries in files and git. Claude did better when told to "use browser automation tools and do all testing as a human user would". |
| [Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) | "As the length of autonomous tasks grows, Claude needs to verify correctness without continuous human feedback. Tools that let Claude verify UI work are helpful". |
| [Improving frontend design through Skills](https://claude.com/blog/improving-frontend-design-through-skills), 2025-11-12 | A skill can encode "your company's design system, specific component patterns, or industry-specific UI conventions". "too many tokens in the context window can result in degradation of performance". |

Anthropic's frontend material pushes toward distinctive design. The harness post counts "template
layouts, library defaults" as a failure of originality, and the `frontend-design` skill is written
for new work. The fault seen here is the opposite one, so a grader for an established app needs a
criterion those sources don't have: the page matches the app's existing patterns. That reading is
the subagent's inference.

## What others publish

| Source | Kind | What it says |
| --- | --- | --- |
| [Google `DESIGN.md`](https://github.com/google-labs-code/design.md), alpha | spec | "DESIGN.md gives agents a persistent, structured understanding of a design system." Its linter checks the rules file, never the app's code. |
| [Alter, "Agentic design system"](https://designproject.io/blog/agentic-design-system-context/), 2026-08-28 | opinion | "The agent simply didn't understand where the system lived, when to consult it, or which parts of it were mandatory." "A component existing in Storybook does not guarantee the agent will reach for it." Rules: "Reuse existing components before creating new ones." "If the design system does not cover a need, ask before inventing a token, radius, component, or interaction pattern." |
| [Gregory, Kasava, "Self-Enforcing Design System"](https://www.kasava.dev/blog/self-enforcing-design-system-claude-code), 2025-12-09 | team write-up | A `DESIGN_PRINCIPLES.md` at the repo root, each principle one Claude can check, and "a dedicated `design-review` agent that uses Playwright to actually interact with our UI". No counts. |
| [Opalic, design-token lint](https://alexop.dev/posts/enforce-tailwind-design-system-shadcn-lint/), 2026-09-27 | write-up | "Telling it to follow the design system gives it instructions. It also needs a way to check its work." Lint rules ban raw colors, arbitrary values, and restyled components. |
| [Kinney, visual regression as a feedback loop](https://stevekinney.com/courses/self-testing-ai-agents/visual-regression-as-a-feedback-loop), 2026-04-14 | course | "Nothing in your test suite catches that, because no test asserts on visual appearance." |
| [MacMyths, visual regression](https://macmyths.com/visual-regression-with-playwright-keep-ai-coded-pages-consistent/), 2026-10-30 | write-up | "Treat the first render as a design review, not as an automatically correct specification." "Only after that human review should you commit the reference images." |
| [kent-tokyo, DEV](https://dev.to/kent-tokyo/what-i-do-before-letting-claude-code-touch-web-app-design-53n0) | opinion | Tokens before components. "Naming a reference directly reduces variation in the output." |
| ETH Zurich, "Evaluating AGENTS.md" (Gloaguen et al., 2026-02) | measured, snippet | Generated context files lowered task success by about 3% and raised cost over 20%; human-written ones gained about 4%. Read only through secondary write-ups. |

## What no source covers

- A measured result that a rules file, a component inventory, or a reuse rule cuts one-off pages.
- A lint rule or hook that catches a route that skipped a named shared layout or component. The
  published rules catch raw values and restyling only.
- A reviewer's rubric for "this diff reuses the app's existing components".
- Who approves a prototype before an unattended executor builds from it.
- A visual-regression baseline can't flag a new page, because the page's first run creates it.
