<%*
const project = await tp.system.prompt("Nome del progetto (es. WSpace)");
const filename = `Dashboard-${project}.md`;
const path = `${project}/${filename}`;

let content = `# 📊 Dashboard: ${project}

> Tutti i documenti relativi al progetto  ${project}, ordinati per tipo e data.

---

## 🐞 Bug Reports

\`\`\`dataview
TABLE feature, category, severity, date, file.link AS "Visualizza"
FROM ""
WHERE type = "Bug" AND project = "${project}"
SORT date DESC
\`\`\`

## 📚 Documenti Tecnici

\`\`\`dataview
TABLE feature, topic, programming_languages, date, file.link AS "Visualizza"
FROM ""
WHERE type = "Documento Tecnico" AND project = "${project}"
SORT date DESC
\`\`\`

## 📐 Documenti di Analisi

\`\`\`dataview
TABLE feature, topic, date, file.link AS "Visualizza"
FROM ""
WHERE type = "Documento Analisi" AND project = "${project}"
SORT date DESC
\`\`\`

## 📓 Rapportini

\`\`\`dataview
TABLE feature, topic, time, status, date, file.link AS "Visualizza"
FROM ""
WHERE type = "Rapportino" AND project = "${project}"
SORT date DESC
\`\`\`

## 📝 Istruzioni

\`\`\`dataview
TABLE feature, topic, date, file.link AS "Visualizza"
FROM ""
WHERE type = "Istruzioni" AND project = "${project}"
SORT date DESC
\`\`\`

## 📣 Verbali / Riunioni

\`\`\`dataview
TABLE feature, topic, time, date, file.link AS "Visualizza"
FROM ""
WHERE type = "Verbale" AND project = "${project}"
SORT date DESC
\`\`\`

## ⏱️ Totale Tempo Tracciato

\`\`\`dataview
TABLE sum(toNumber(time)) as "Tempo Totale (h)"
FROM ""
WHERE project = "${project}"
\`\`\`
`;

const folders = path.split("/").slice(0, -1).join("/");
if (!(await app.vault.adapter.exists(folders))) {
  await app.vault.createFolder(folders);
}

if (!(await app.vault.adapter.exists(path))) {
  await app.vault.create(path, content);
  new Notice(`✅ File creato: ${path}`);
} else {
  new Notice(`⚠️ File già esistente: ${path}`);
}
%>
