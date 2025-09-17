<%*
const difficoltàLivelli = ["bassa", "media", "alta"];
const statoLivelli = ["approvato", "in revisione", "da approvare"];

const progetto = await tp.system.prompt("Progetto?");
const feature = await tp.system.prompt("Feature?");
const topic = await tp.system.prompt("Titolo procedura?");
const linkedTo = await tp.system.prompt("File Istruzioni da collegare?");
const difficoltà = await tp.system.suggester(difficoltàLivelli, difficoltàLivelli, true, "Difficoltà?");
const stato = await tp.system.suggester(statoLivelli, statoLivelli, true, "Stato?");
const oggi = tp.date.now("YYYY-MM-DD");

const filename = `Procedura-${feature}-${topic}-${tp.date.now("YYYYMMDD")}.md`;
const folderPath = `${progetto}/Procedure`;
const fullPath = `${folderPath}/${filename}`;

let content = `---
project: ${progetto}
feature: ${feature}
type: Procedura
topic: ${topic}
related_to: [[${linkedTo}]]
difficulty: ${difficoltà}
status: ${stato}
date: ${oggi}
tags: ["${progetto}", "${feature}", "Procedura", "${topic}"]
---

\`\`\`table-of-contents
Style: nestedList
MaxLevel: 0
IncludeLinks: true
DebugInConsole: false
\`\`\`

# 🔧 Procedura

Descrivi gli step operativi dettagliati.
`;

if (!(await app.vault.adapter.exists(folderPath))) {
  await app.vault.createFolder(folderPath);
}
if (!(await app.vault.adapter.exists(fullPath))) {
  await app.vault.create(fullPath, content);
  new Notice(`✅ Procedura creata: ${fullPath}`);
} else {
  new Notice(`⚠️ Procedura già esistente: ${fullPath}`);
}

await app.workspace.openLinkText(fullPath, '', false);
%>
