# osmeng-agent-starter

Installs the Agent Skills repos from your [Skills stars list](https://github.com/stars/elhaddajiOtmane/lists/skills) **plus** the 6 extra packs you asked for (`chrome-devtools-mcp`, `gh CLI`, `Context7`, `agent-swarm-spawner`, `mcp-supersubagents`, `superpowers`) into the places [OpenCode](https://opencode.ai) looks for skills. One script, no manual cloning/copying per repo.

> Named it "osmeng" per the ask — rename the folder if you meant something else, nothing else depends on the name.

## Quick start

```bash
chmod +x install.sh
./install.sh            # installs ~130 skills to ~/.config/opencode/skills/ (global)
./install.sh --dry-run  # preview without writing
```

Then restart OpenCode / start a new session and ask it to list its skills to confirm. See [## Wire up MCP servers & CLIs](#wire-up-mcp-servers--clis) below for the one-time MCP/CLI setup (Chrome, gh, Context7, supersubagents).

## Flags

| Flag | Effect |
|---|---|
| `--scope global` | (default) installs to `~/.config/opencode/skills/` — available in every project |
| `--scope project` | installs to `./.opencode/skills/` — run it from inside the project you want them in |
| `--include-mega` | also pulls the two huge collections (ECC: 286 skills, OmniRoute: 46) — see below before turning this on |
| `--force` | overwrite skills that already exist locally (use to pull updates) |
| `--dry-run` | print what would happen, write nothing |

## Why this works

OpenCode discovers skills by walking a fixed set of paths and loading every `skills/<name>/SKILL.md` it finds:

- `~/.config/opencode/skills/` (global, native)
- `.opencode/skills/` (project, native)
- `~/.claude/skills/` and `.claude/skills/` (Claude Code compatibility)
- `~/.agents/skills/` and `.agents/skills/` (generic agents.md compatibility)

The script only writes the native `opencode/` path — if you already have skills under `~/.claude/skills/` from Claude Code, OpenCode is already reading those too, no action needed.

Plus a ready-to-copy MCP block in [`opencode.mcp.example.json`](./opencode.mcp.example.json) for the servers that need runtime wiring (Chrome DevTools, Context7, supersubagents).

## What's included

### Core (installed by default, 86 skills)

| Source | Skills | What it is |
|---|---|---|
| [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) | 13 | Design-taste / anti-generic-slop skills |
| [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | 6 | Minimal-diff, lean coding discipline |
| [AgriciDaniel/claude-seo](https://github.com/AgriciDaniel/claude-seo) *(core only)* | 25 | Technical SEO — sitemap, schema, GEO/AEO, content, audits |
| [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) | 5 | Obsidian CLI, Bases, JSON Canvas, Markdown |
| [mattpocock/skills](https://github.com/mattpocock/skills) | 37 | Engineering + productivity workflows (TDD, code review, spec-writing, handoffs) |

claude-seo ships 8 more skills under `extensions/<provider>/` (Ahrefs, SE Ranking, DataForSEO, Bing Webmaster, Profound, Firecrawl, unlighthouse, an image-gen one) — each needs that provider's API key, so they're not auto-installed. Copy the ones you actually pay for from a manual clone.

mattpocock's skills are nested by category (`skills/engineering/tdd/`, `skills/productivity/handoff/`, etc). The installer flattens that and prefixes the name — e.g. `engineering-tdd`, `productivity-handoff` — so they land as normal top-level skills without colliding.

### Requested add-ons (installed by default, +44 skills / 1 MCP)

These are the 6 you asked to add — they now install automatically every run:

| Source | Skills | What it is | Also needs |
|---|---|---|---|
| [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) | 6 | Browser automation + perf/a11y/memory debugging. Skills: `a11y-debugging`, `chrome-devtools`, `chrome-devtools-cli`, `debug-optimize-lcp`, `memory-leak-debugging`, `troubleshooting` | Chrome + Node LTS · MCP server `npx -y chrome-devtools-mcp@latest` |
| [cli/cli](https://github.com/cli/cli) | 2 | GitHub CLI skills: `gh` (patterns for `gh` from agents) + `gh-skill` (skill lifecycle). `gh` itself from [cli.github.com](https://cli.github.com/) | `gh` binary: `winget install --id GitHub.cli` / `brew install gh` → `gh auth login` |
| [upstash/context7](https://github.com/upstash/context7) | 3 | Up-to-date library docs. Skills: `context7-cli`, `context7-mcp`, `find-docs` | `npx ctx7 setup --opencode` **or** plugin `@upstash/context7-opencode` **or** remote MCP `https://mcp.context7.com/mcp` |
| [c-daly/agent-swarm](https://github.com/c-daly/agent-swarm) | 19 | The repo behind [mcpmarket.com/tools/skills/agent-swarm-spawner](https://mcpmarket.com/tools/skills/agent-swarm-spawner). Swarm orchestration: `spawn`, `orchestrate`, `parallel-orchestrate`, `delegate`, `develop`, `implement`, … | Claude Code: `claude plugin install agent-swarm`. For OpenCode: skills already work; no MCP needed |
| [obra/superpowers](https://github.com/obra/superpowers) | 14 | Workflow superpowers: `brainstorming`, `tdd`, `systematic-debugging`, `dispatching-parallel-agents`, `writing-plans`, … | OpenCode plugin `superpowers@git+https://github.com/obra/superpowers.git` (already in your global `opencode.json` if you used this starter before) |
| [yigitkonur/mcp-supersubagents](https://github.com/yigitkonur/mcp-supersubagents) | 0 *(MCP only)* | Parallel Codex/Copilot/Claude subagents with dependencies + auto-rotation (8 tools) | MCP server: `npx -y mcp-supersubagents` — no SKILL.md to copy |

Total default install: **86 + 44 + 0 = 130 skills** + 1 pure MCP server.

### Mega, opt-in (`--include-mega`)

| Source | Skills | What it is |
|---|---|---|
| [affaan-m/ECC](https://github.com/affaan-m/ECC) | 286 | General-purpose skill library — languages, frameworks, security, compliance, agent-harness patterns, basically everything |
| [diegosouzapw/OmniRoute](https://github.com/diegosouzapw/OmniRoute) | 46 | Skills for driving OmniRoute itself (an AI gateway to 350+ model providers) — only useful if you actually run OmniRoute |

286 skill descriptions all loaded at once is a lot of context for OpenCode's skill tool to list on every turn. Before flipping `--include-mega` on, consider cherry-picking: `git clone --depth 1 https://github.com/affaan-m/ECC`, then copy just the folders you want into `~/.config/opencode/skills/`.

### Not scripted — different shape, check the repo directly

| Source | Why it's not a simple copy |
|---|---|
| [ruvnet/ruflo](https://github.com/ruvnet/ruflo) | Full agent orchestration framework (350+ skills live inside its own plugin system and need the ruflo runtime running) |
| [thedotmack/claude-mem](https://github.com/thedotmack/claude-mem) | Session-memory plugin — its skills act on data its own hook/backend captures, so it needs the real install, not just the SKILL.md folders |
| [headroomlabs-ai/headroom](https://github.com/headroomlabs-ai/headroom) | A token-compression proxy/MCP server — a running service, not a skill |
| [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) | Reference `DESIGN.md` files meant to be dropped into a project root, not SKILL.md format |

### Companion CLIs (tools your skills might shell out to)

[supabase/cli](https://github.com/supabase/cli) · [microsoft/playwright](https://github.com/microsoft/playwright) · [microsoft/playwright-cli](https://github.com/microsoft/playwright-cli) · [TestSprite/testsprite-cli](https://github.com/TestSprite/testsprite-cli) — install each via its own repo's instructions, not this script.

Plus the CLIs for the add-ons above: `gh` ([cli.github.com](https://cli.github.com/)), `ctx7` ([upstash/context7](https://github.com/upstash/context7)), `chrome-devtools-mcp` ([ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp)), `mcp-supersubagents` ([yigitkonur/mcp-supersubagents](https://github.com/yigitkonur/mcp-supersubagents)).

**Skipped entirely:** `lightningpixel/modly` (a 3D-model desktop app, unrelated to agents/skills).

## Wire up MCP servers & CLIs

`./install.sh` handles the **skills** (SKILL.md files). The MCP servers/CLIs that power them need a one-time wiring. The installer prints these at the end too — this is the same info in copy-paste form.

### 1) Chrome DevTools MCP — browser automation

Already in `~/.config/opencode/opencode.json` as `chrome-devtools` if you ran this starter before — just flip `enabled` to `true`:

```json
"mcp": {
  "chrome-devtools": {
    "type": "local",
    "command": ["npx", "-y", "chrome-devtools-mcp@latest", "--browser-url=http://127.0.0.1:9222"],
    "enabled": true
  }
}
```

Requires Chrome (stable) + Node LTS. Launch Chrome with remote debugging if you use `--browser-url` (or omit the flag to let it launch Chrome itself).

### 2) GitHub CLI (`gh`)

```bash
# Windows
winget install --id GitHub.cli
# macOS
brew install gh
# then
gh auth login
# optional: install the gh skill via gh itself (user scope)
gh skill install cli/cli gh --scope user
```

Docs: [cli.github.com](https://cli.github.com/) · Skills installed: `gh`, `gh-skill`.

### 3) Context7 — up-to-date docs

Pick **one** of these (they all work; the first is fastest):

```bash
# Option A — auto-wires Context7 skill + MCP for OpenCode
npx ctx7 setup --opencode

# Option B — OpenCode plugin (adds MCP + skill via plugin manager)
# add to opencode.json -> "plugin": ["@upstash/context7-opencode", ...]
npm i -g ctx7   # or just use npx

# Option C — raw remote MCP in opencode.json
"mcp": { "context7": { "type": "remote", "url": "https://mcp.context7.com/mcp", "enabled": true } }
```

CLI usage after: `ctx7 docs /vercel/next.js "how to do middleware"` · Skills: `context7-cli`, `context7-mcp`, `find-docs`.

### 4) Agent Swarm — the "agent-swarm-spawner" listing

- MCPMarket page: [mcpmarket.com/tools/skills/agent-swarm-spawner](https://mcpmarket.com/tools/skills/agent-swarm-spawner)
- Real repo: [c-daly/agent-swarm](https://github.com/c-daly/agent-swarm) — 19 skills already installed by `./install.sh`
- For Claude Code: `claude plugin install agent-swarm` (registers router MCP + hooks)
- For OpenCode: no extra MCP needed — `spawn`, `orchestrate`, `parallel-orchestrate`, `delegate`, etc. work as plain skills

### 5) Superpowers

If your `opencode.json` already has this, you're done:

```json
"plugin": ["superpowers@git+https://github.com/obra/superpowers.git"]
```

If not, add it and restart OpenCode — then ask "tell me about your superpowers". 14 skills: `brainstorming`, `tdd`, `systematic-debugging`, `dispatching-parallel-agents`, …

### 6) Super Subagents (parallel Codex/Copilot/Claude)

Pure MCP server, no SKILL.md. Add to `opencode.json`:

```json
"mcp": {
  "supersubagents": {
    "type": "local",
    "command": ["npx", "-y", "mcp-supersubagents"],
    "enabled": true
  }
}
```

Requires Node 18+. Provides 8 tools (`launch-super-coder`, `launch-super-planner`, `spawn`, `cancel-task`, …) with auto-rotation on 429/5xx.

### Full example block

Copy the `mcp` + `plugin` keys from [`opencode.mcp.example.json`](./opencode.mcp.example.json) into your `~/.config/opencode/opencode.json` (or the project `.opencode/opencode.json` if you used `--scope project`).

## Updating

Re-run with `--force` to pull the latest version of everything already installed:

```bash
./install.sh --force
```

Name collisions between sources (e.g. both `claude-seo` and `ECC` ship a skill literally named `seo`) are detected and skipped rather than silently overwritten — rerun with `--force` if you want the later source to win.

## Full reference

`sources.json` has the same breakdown above in a structured form, plus the exact repo path/depth used for each source — useful if you want to add your own.
