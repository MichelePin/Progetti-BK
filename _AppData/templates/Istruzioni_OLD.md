<%*
const progetti = ["WSpace", "Varie", "Inbox", "Globale"];
const funzionalità = ["Inventario", "Login", "Ordini", "Deploy", "Debug"];
const argomenti = ["Installazione", "Nuovo flusso", "Procedura", "Fix", "Aggiornamento"];
const difficoltàLivelli = ["bassa", "media", "alta"];

const progetto = await tp.system.suggester(progetti, progetti, true, "Seleziona il progetto");
const feature = await tp.system.suggester(funzionalità, funzionalità, true, "Seleziona la feature");
const topic = await tp.system.suggester(argomenti, argomenti, true, "Seleziona l'argomento delle istruzioni");
const linkedDocs = await tp.system.prompt("Documenti correlati (opzionale)");

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

```table of contents
```

# 📖 Introduzione

Descrizione sintetica della procedura o del fix.

# ⚠️ Prima di Iniziare

Indicazioni importanti o pre-condizioni.

# ✅ Requisiti

## Fondamentali
- Connessione stabile
- Permessi di amministratore

## Opzionali
- Tool opzionali, estensioni o dati di test

# 🛠️ Procedimento

## Step 1


## Step 2
- [ ] Installare la nuova versione del componente  
  project:: ${progetto}  
  feature:: ${feature}  
  topic:: ${topic}  
  type:: task  
  area:: installazione  
  status:: todo  
  difficulty:: media

## Step 3
- [ ] Verificare il funzionamento finale  
  project:: ${progetto}  
  feature:: ${feature}  
  topic:: ${topic}  
  type:: task  
  area:: testing  
  status:: todo  
  difficulty:: alta

# 🧯 Possibili Problemi

- Il componente potrebbe non avviarsi al primo avvio
- Verificare la compatibilità con la versione corrente del database
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
