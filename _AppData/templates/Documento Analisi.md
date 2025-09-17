<%*
const progetti = ["WSpace", "Varie", "AltroProgetto"];
const funzionalità = ["Inventario", "Login", "Ordini"];
const progetto = await tp.system.suggester(progetti, progetti, true, "Seleziona il progetto");
const feature = await tp.system.suggester(funzionalità, funzionalità, true, "Seleziona la feature");
const linkedDocs = await tp.system.prompt("Documenti correlati (opzionale)");

const oggi = tp.date.now("YYYY-MM-DD");
const filename = `${feature}-DocumentoAnalisi-${tp.date.now("YYYYMMDD")}.md`;
const folderPath = `${progetto}/Documento Analisi`;
const fullPath = `${folderPath}/${filename}`;

const tags = [progetto, feature, "Documento Analisi"];

let content = `---
project: ${progetto}
feature: ${feature}
type: Documento Analisi
linked_documents: ${linkedDocs}
date: ${oggi}
tags: [${tags.map(t => `"${t}"`).join(", ")}]
---

\`\`\`toc
\`\`\`

# Introduzione

Inserisci qui una breve introduzione al documento.

# Obiettivo

Definisci qui gli obiettivi principali.

# Approccio

## Frontend

### Nuovo

#### Componenti
- Componenti creati

#### Flussi
- Flussi creati

#### Logiche
- Logiche create

### Modificato

#### Componenti
- Componenti modificati

#### Flussi
- Flussi modificati

#### Logiche
- Logiche modificate

## Backend

### Nuovo
- Endpoint, servizi, logiche nuove

### Modificato
- Servizi o controller modificati

## Database

### Nuovo
- Tabelle, colonne, relazioni

### Modificato
- Cambi strutturali, ottimizzazioni

# Possibili Problemi

Elenco dei problemi previsti o rischi potenziali.

# Conclusione

Considerazioni finali, discussioni aperte o follow-up.

# ✅ Tasks (referenziabili globalmente)

## Frontend
- [ ] Implementare il componente principale  
  project:: ${progetto}  
  feature:: ${feature}  
  area:: frontend  
  type:: task  
  status:: todo  
  difficulty:: alta

## Backend
- [ ] Creare endpoint API iniziale  
  project:: ${progetto}  
  feature:: ${feature}  
  area:: backend  
  type:: task  
  status:: todo  
  difficulty:: media

## Database
- [ ] Definire tabella intermedia  
  project:: ${progetto}  
  feature:: ${feature}  
  area:: database  
  type:: task  
  status:: todo  
  difficulty:: bassa

## Documentazione
- [ ] Scrivere documentazione base  
  project:: ${progetto}  
  feature:: ${feature}  
  area:: documentation  
  type:: task  
  status:: todo  
  difficulty:: bassa
`;

const folders = fullPath.split("/").slice(0, -1).join("/");

if (!(await app.vault.adapter.exists(folders))) {
  await app.vault.createFolder(folders);
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
