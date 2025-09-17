<%*


const project = await tp.system.prompt("Progetto?");
const time = await tp.system.prompt("Tempo Impiegato?");
const oggi = tp.date.now("YYYY-MM-DD");
const shortDate = tp.date.now("MMDD");
const month = tp.date.now("MMMM");
const version = "2.60.2";
const documentType = "Rapportino";
const fileName = `${documentType}-${shortDate}.md`;
const folderPath = `${project}/Rapportini/${month}/`;
const fullPath = `${folderPath}${fileName}`;
const tags = [project, documentType ];
const tagLine = tags.map(t => `#${t.replace(/\s+/g, '')}`).join(' ');

let content = `---
project: ${project}
type: ${documentType}
time: ${time}
date: ${oggi}
version: ${version}
tags: [${tags.map(t => `"${t}"`).join(", ")}]
---
**Tags**

${tagLine}

\`\`\`table-of-contents
maxLevel: 1
\`\`\`

# Introduzione


Attività svolta in data ${oggi}, tempo impiegato: **${time}**.

# Cambiamenti Effettuati

Elenca modifiche, miglioramenti, fix o test.




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
