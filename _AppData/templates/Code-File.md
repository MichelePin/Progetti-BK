<%*
const project = await tp.system.prompt("Progetto?");
const noteTitle = await tp.system.prompt("Titolo?");
const language = await tp.system.prompt("Linguaggio?");
const repo = await tp.system.prompt("Repo da collegare?");
const today = tp.date.now("YYYY-MM-DD");
const version = "2.60.2";
const documentType = "Code-File";
const fileName = `${noteTitle}-${language}.md`;
const folderPath = `${project}/_db/code/${language}/`;
const fullPath = `${folderPath}${fileName}`;
const tags = [project, language, "Code", repo];
const tagLine = tags.map(t => `#${t.replace(/\s+/g, '')}`).join(' ');

let content = `---
project: ${project}
programming_languages: ${language}
type: ${documentType}
date: ${today}
version: ${version}
repo: ${repo}
tags: [${tags.map(t => `"${t}"`).join(", ")}]
---
**Tags**

${tagLine}

\`\`\`table-of-contents
maxLevel: 1
\`\`\`

# Introduzione

Descrizione del file e la sua funzionalità


# Codice 
\`\`\`${language} cpp fold title:${noteTitle} 
// 
//

\`\`\`

# Change Log
## ${version}

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
