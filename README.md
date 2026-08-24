# osmeng-agent-starter

Installs the Agent Skills repos from your [Skills stars list](https://github.com/stars/elhaddajiOtmane/lists/skills) into the places [OpenCode](https://opencode.ai) looks for skills. One script, no manual cloning/copying per repo.

> Named it "osmeng" per the ask — rename the folder if you meant something else, nothing else depends on the name.

## Quick start

```bash
chmod +x install.sh
./install.sh
```

That installs the **core set** (86 skills, 5 repos) to `~/.config/opencode/skills/`. Restart OpenCode / start a new session and ask it to list its skills to confirm.

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

## What's included

### Core (installed by default)

| Source | Skills | What it is |
|---|---|---|
| [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) | 13 | Design-taste / anti-generic-slop skills |
| [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | 6 | Minimal-diff, lean coding discipline |
| [AgriciDaniel/claude-seo](https://github.com/AgriciDaniel/claude-seo) *(core only)* | 25 | Technical SEO — sitemap, schema, GEO/AEO, content, audits |
| [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) | 5 | Obsidian CLI, Bases, JSON Canvas, Markdown |
| [mattpocock/skills](https://github.com/mattpocock/skills) | 37 | Engineering + productivity workflows (TDD, code review, spec-writing, handoffs) |

claude-seo ships 8 more skills under `extensions/<provider>/` (Ahrefs, SE Ranking, DataForSEO, Bing Webmaster, Profound, Firecrawl, unlighthouse, an image-gen one) — each needs that provider's API key, so they're not auto-installed. Copy the ones you actually pay for from a manual clone.

mattpocock's skills are nested by category (`skills/engineering/tdd/`, `skills/productivity/handoff/`, etc). The installer flattens that and prefixes the name — e.g. `engineering-tdd`, `productivity-handoff` — so they land as normal top-level skills without colliding.

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

**Skipped entirely:** `lightningpixel/modly` (a 3D-model desktop app, unrelated to agents/skills).

## Updating

Re-run with `--force` to pull the latest version of everything already installed:

```bash
./install.sh --force
```

Name collisions between sources (e.g. both `claude-seo` and `ECC` ship a skill literally named `seo`) are detected and skipped rather than silently overwritten — rerun with `--force` if you want the later source to win.

## Full reference

`sources.json` has the same breakdown above in a structured form, plus the exact repo path/depth used for each source — useful if you want to add your own.
