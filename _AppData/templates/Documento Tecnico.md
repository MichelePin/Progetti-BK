<%*
const progetti = ["WSpace", "Varie", "Generale"];
const funzionalità = ["Inventario", "Login", "Ordini"];
const linguaggi = ["TypeScript", "C#", "SQL", "JavaScript", "Altro"];
const argomenti = ["Componente", "Flusso", "Endpoint", "Funzione", "Utility"];

const progetto = await tp.system.suggester(progetti, progetti, true, "Seleziona il progetto");
const feature = await tp.system.suggester(funzionalità, funzionalità, true, "Seleziona la feature");
const topic = await tp.system.suggester(argomenti, argomenti, true, "Argomento tecnico");
const programmingLanguage = await tp.system.suggester(linguaggi, linguaggi, true, "Linguaggio principale");
const linkedDocs = await tp.system.prompt("Documenti correlati (opzionale)");

const oggi = tp.date.now("YYYY-MM-DD");
const filename = `${feature}-DocumentoTecnico-${topic}-${tp.date.now("YYYYMMDD")}.md`;
const folderPath = `${progetto}/DocumentoTecnico`;
const fullPath = `${folderPath}/${filename}`;

const tags = [progetto, feature, "Documento Tecnico", topic, programmingLanguage];

let content = `---
project: ${progetto}
feature: ${feature}
type: Documento Tecnico
topic: ${topic}
linked_documents: ${linkedDocs}
programming_languages: ${programmingLanguage}
date: ${oggi}
tags: [${tags.map(t => `"${t}"`).join(", ")}]
---

\`\`\`table-of-contents
Style: nestedList
MaxLevel: 0
IncludeLinks: true
DebugInConsole: false
\`\`\`

# 🧠 Introduzione

Descrizione sintetica della logica tecnica trattata.

# 💻 Codice

## Parte 1 – Spiegazione

- Metodo \`metodo1()\` — descrizione del comportamento  
- Funzione \`function2()\` — spiegazione dell'input/output  

## Esempio di utilizzo

`;

if (!(await app.vault.adapter.exists(folderPath))) {
  await app.vault.createFolder(folderPath);
}

if (!(await app.vault.adapter.exists(fullPath))) {
  await app.vault.create(fullPath, content);
  new Notice(`✅ Documento Tecnico creato: ${fullPath}`);
} else {
  new Notice(`⚠️ Documento già esistente: ${fullPath}`);
}

await app.workspace.openLinkText(fullPath, '', false);

const active = app.workspace.getActiveFile();
if (active?.basename === "Untitled") {
  await app.workspace.activeEditor?.commands?.executeCommandById("workspace:close-active-leaf");
}

%>
