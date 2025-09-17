<!-- .github/copilot-instructions.md - Guidance for AI coding agents working in this repository -->
# Copilot instructions for "Progetti-BK" vault

Purpose
-------
This repository is primarily an Obsidian vault containing documentation, templates, and a _db/code directory with extracted code snippets (C#, SQL, JSON) for the WSpace project. Treat the repo as a documentation-first workspace: most files are MD notes that document APIs, controllers, and database schemas rather than a single runnable application.

What to do first
-----------------
- Index and summarise work in `WSpace/_db/code/` when asked: these files contain canonical examples of controllers (`WAR_OrderController.md`, `WAR_InventoryOrderController.md`, etc.), table definitions (`WAR_PlanningHeader.md`), and JSON schemas. Use them as the source of truth for API shape and DB fields.
- Do not assume there is a build system in this repository. There are no visible solution files (`*.sln`), project manifests (`*.csproj`), `package.json`, or dockerfiles at the repo root. If asked to run or modify code, request or confirm the target repo that contains the actual services or provide changes as patches/snippets to these MD code blocks.

Key locations and examples
---------------------------
- `WSpace/_db/code/Csharp/` — API controller docs. Example: `WAR_OrderController.md` describes endpoints like `CreateNewOrder` and `GetOrderList`.
- `WSpace/_db/code/SQL/` — Database schemas and table DDL. Example: `WAR_PlanningHeader.md` contains the `WAR_PlanningHeader` table DDL and field explanations.
- `WSpace/_db/code/Json/` — Enumerations and JSON payload examples used by controllers (e.g., `PlanningHeaderType-Json.md`).
- `_AppData/templates/` — Obsidian Templater helper templates and README explaining how to use them inside Obsidian.

Conventions and patterns to preserve
-----------------------------------
- Documentation-first edits: prefer updating the `.md` source files (maintain their frontmatter) rather than creating new code projects in the repo.
- When editing code blocks inside `.md` files, keep the code fenced block language (e.g. ```C# or ```SQL) and add minimal, well-scoped diffs — these files are living documentation extracted from the codebase.
- Versioning in headings: many files include a `Versione` or `Change Log` section. When making changes that you document here, add a short change-log entry with a date/version to the top of the file.

Developer workflows (what humans do here)
-----------------------------------------
- Editing docs: Open the MD files in Obsidian (or a text editor) and update code blocks and prose. Templates live in `_AppData/templates` and rely on the Obsidian Templater plugin.
- Applying code changes: This repo is a documentation vault. To propose real code changes, generate patches (git diffs) the maintainers can apply to the actual code repositories (ask user where the live repo is).

When asked to implement features or bug fixes
--------------------------------------------
- Prefer creating a concise patch or a code snippet that can be copy-pasted into the canonical service repo. Include: changed function, a short rationale, and test suggestions.
- If the user asks to run or test code, point out that this repo lacks the runnable project files and request the target service repo or relevant build files.

Examples to cite in suggestions
-------------------------------
- To extend order handling, reference `WSpace/_db/code/Csharp/WAR_OrderController.md` and `WSpace/_db/code/SQL/WAR_PlanningHeader.md` for column/field names like `OrderMode`, `OrderStatus`, and `FilterItemNo`.
- To add a new enum or JSON payload, add a new file under `WSpace/_db/code/Json/` mirroring existing names and link it from controller docs.

Edge cases and guardrails for AI edits
-------------------------------------
- Never assume runnable context: explicitly state when a change is only to documentation and not executable.
- Preserve frontmatter blocks in `.md` files; do not remove YAML metadata.
- Avoid introducing new binary files or compiled artifacts into the vault.

If you cannot find expected code
--------------------------------
- Ask the user where the canonical service repository lives (this vault is a mirror of docs and snippets).
- If the user asks to run tests or builds, request the path to the service repository containing solution/project files.

How to propose a change
------------------------
1. Edit the relevant `.md` file and update the code block and changelog. Keep changes minimal.
2. Provide a separate patch (git diff) that the repository owner can apply to the live codebase, or supply the exact file and line edits needed in the target repo.

Contact/Attribution
--------------------
If unsure about intent or target repo for code changes, ask the user to confirm. Prefer clarity over making runnable assumptions.

-- End of instructions
