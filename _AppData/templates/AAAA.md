<%*
const dbprojects = await tp.user.database("projects");
const dbprogrammingLanguages = await tp.user.database("programmingLanguages");
const version = await tp.user.database("version");

const projects = dbprojects.map(item => item.toString());
const programmingLanguages = dbprogrammingLanguages.map(item => item.toString());


const progetto = await tp.system.suggester(projects, true, "Seleziona il progetto");
const tempo = await tp.system.prompt("Tempo dedicato all'attività (es. 2h)");

const oggi = tp.date.now("YYYY-MM-DD");
const filename = `Rapportino-${tp.date.now("MMDD")}.md`;
const folderPath = `${progetto}/Rapportini`;
const fullPath = `${folderPath}/${filename}`;

const tags = [progetto, "Rapportino"];

let content = `---
project: ${progetto}
type: Rapportino
version: ${version}
time: ${tempo}
date: ${oggi}
tags: [${tags.map(t => `"${t}"`).join(", ")}]
---

\`\`\`table-of-contents
maxLevel: 1
\`\`\`

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
