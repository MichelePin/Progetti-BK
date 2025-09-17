Templater templates for this vault
===============================

This folder contains templates used with the Obsidian Templater plugin. Two helper files are included:

- `Create new note from template - prompt.md`: interactive template that prompts for a template path, filename, and optional folder, then creates and opens the new note.

How to use
----------

1. Install and enable the Templater community plugin in Obsidian.
2. Configure Templater's Templates folder path to include this `_AppData/templates` directory, or call the template by full path.
3. Open the Command Palette in Obsidian and run `Templater: Insert template` then choose `Create new note from template - prompt.md`.
4. When prompted, provide:
   - Template path (relative to vault root), e.g. `_AppData/templates/Documento Tecnico.md`
   - Filename (without `.md`)
   - Optional destination folder (relative to vault root), e.g. `WSpace/Documento Analisi`

Troubleshooting
---------------

- If you see `Template not found: ...` make sure you typed the template path correctly and that the file exists in the vault.
- If the new note is created as `Untitled`, this template uses `tp.file.create_new(tfile, destinationPath, true)` which opens the created file. Ensure your Templater plugin is up to date. If your Obsidian settings or other plugins intercept file creation, try disabling conflicting plugins temporarily.

Optional improvements
---------------------

- You can add frontmatter to templates and modify the helper template to read frontmatter variables to auto-name files.
- If you prefer a picker UI for templates/folders, you can extend the JS to scan vault folders (using `tp.file.find_tfile` or the Vault API) and present choices.

License / Notes
----------------
Small convenience helper created for this vault. Keep it in `_AppData/templates` for consistency with other template files.

Auto-naming with frontmatter
----------------------------

To avoid creating `Untitled` notes and to let templates suggest a filename automatically, add YAML frontmatter to your templates. Example frontmatter at the top of a template:

```yaml
---
title: "Documento Tecnico - <% tp.date.now("YYYY-MM-DD") %>"
tags: [documento, tecnico]
---
```

Then, when using Templater you can extract `title` from the template's frontmatter and use it as the destination filename. The following minimal Templater JS (drop into a template or adapt the interactive helper) shows the idea:

```js
// assume `tplFile` is a TFile for the chosen template
const fm = await tp.frontmatter.render(tplFile.path); // renders templater templating inside frontmatter if any
const suggestedTitle = fm && fm.title ? fm.title : await tp.system.prompt("Filename (without extension)");
const safeName = suggestedTitle.replace(/[\\/:*?"<>|]+/g, "-");
const dest = (folderPath? folderPath + '/' : '') + safeName + '.md';
await tp.file.create_new(tplFile, dest, true);
```

Notes:
- `tp.frontmatter.render(...)` may require newer Templater versions; if unavailable, parse the template file content and extract YAML frontmatter manually.
- Sanitise `title` values to remove characters invalid for filenames on your OS.

