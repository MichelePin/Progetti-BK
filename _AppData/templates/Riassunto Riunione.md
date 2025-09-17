<%*
const progetti = ["WSpace", "Varie", "AltroProgetto"];
const funzionalità = ["Inventario", "Login", "Ordini"];
const argomenti = ["Sviluppo", "Nuovo flusso", "Procedure", "Revisione", "Pianificazione"];
const tempo = await tp.system.prompt("Tempo dedicato alla riunione (es. 1.5h)");

const progetto = await tp.system.suggester(progetti, progetti, true, "Seleziona il progetto");
const feature = await tp.system.suggester(funzionalità, funzionalità, true, "Seleziona la feature");
const topic = await tp.system.suggester(argomenti, argomenti, true, "Argomento della riunione");
const linkedDocs = await tp.system.prompt("Documenti collegati (opzionale)");
const linkedMeetings = await tp.system.prompt("Altri verbali correlati (opzionale)");

const oggi = tp.date.now("YYYY-MM-DD");
const filename = `${feature}-Verbale-${topic}-${tp.date.now("YYYYMMDD")}`;
const folderPath = `${progetto}/Verbale`;
const fullPath = `${folderPath}/${filename}`;

const tags = [progetto, feature, "Verbale", topic];

let content = `---
project: ${progetto}
feature: ${feature}
type: Verbale
topic: ${topic}
linked_documents: ${linkedDocs}
linked_meetings: ${linkedMeetings}
date: ${oggi}
time: ${tempo}
tags: [${tags.map(t => `"${t}"`).join(", ")}]
---

\`\`\`table-of-contents
Style: nestedList
MaxLevel: 0
IncludeLinks: true
DebugInConsole: false
\`\`\`

# 🎯 Scopo della Riunione

Descrizione del motivo dell’incontro e degli obiettivi principali.

# 📝 Punti Salienti

- Punto 1 rilevante
- Punto 2 rilevante
- Punto 3 importante

# ✅ Action Items

## Task concordate

- [ ] Implementare nuova logica nel flusso \`X\`  
  project:: ${progetto}  
  feature:: ${feature}  
  topic:: ${topic}  
  type:: task  
  status:: todo  
  area:: backend  
  difficulty:: media

- [ ] Creare documento aggiornamento tecnico  
  project:: ${progetto}  
  feature:: ${feature}  
  topic:: ${topic}  
  type:: task  
  status:: todo  
  area:: documentation  
  difficulty:: bassa

# 💬 Considerazioni

Eventuali commenti, follow-up o punti lasciati in sospeso.
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

const active = app.workspace.getActiveFile();
if (active?.basename === "Untitled") {
  await app.workspace.activeEditor?.commands?.executeCommandById("workspace:close-active-leaf");
}
%>
