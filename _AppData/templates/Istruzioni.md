<%*
const progetti = ["WSpace", "Varie", "Inbox", "Globale"];
const funzionalità = ["Inventario", "Login", "Ordini", "Deploy", "Debug"];
const argomenti = ["Installazione", "Nuovo flusso", "Procedura", "Fix", "Aggiornamento"];

const progetto = await tp.system.suggester(progetti, progetti, true, "Progetto?");
const feature = await tp.system.suggester(funzionalità, funzionalità, true, "Feature?");
const topic = await tp.system.suggester(argomenti, argomenti, true, "Argomento?");
const linkedDocs = await tp.system.prompt("Documenti correlati?");
const oggi = tp.date.now("YYYY-MM-DD");

const filename = `${feature}-Istruzioni-${topic}-${tp.date.now("YYYYMMDD")}.md`;
const folderPath = `${progetto}/Istruzioni`;
const fullPath = `${folderPath}/${filename}`;

const tags = [progetto, feature, "Istruzioni", topic];

let content = `---
project: ${progetto}
feature: ${feature}
type: Istruzioni
topic: ${topic}
linked_documents: ${linkedDocs}
date: ${oggi}
tags: [${tags.map(t => `"${t}"`).join(", ")}]
---

\`\`\`table-of-contents
style: nestedList
maxLevel: 0
includeLinks: true
debugInConsole: false
\`\`\`

# 📖 Introduzione

# ⚠️ Prima di Iniziare

# ✅ Requisiti

## Fondamentali
- ...

## Opzionali
- ...

# 🛠️ Procedimento

\`\`\`button
name ➕ Aggiungi Procedura
type: templater
template: Procedura
\`\`\`

## 📂 Procedure collegate

\`\`\`dataview
TABLE difficulty, status, file.link AS "Procedura"
FROM ""
WHERE related_to = this.file.link
SORT file.name asc
\`\`\`

# 🧯 Possibili Problemi

`;

if (!(await app.vault.adapter.exists(folderPath))) {
  await app.vault.createFolder(folderPath);
}
if (!(await app.vault.adapter.exists(fullPath))) {
  await app.vault.create(fullPath, content);
  new Notice(`✅ File creato: ${fullPath}`);
} else {
  new Notice(`⚠️ File già esistente: ${fullPath}`);
}

await app.workspace.openLinkText(fullPath, '', false);
%>

