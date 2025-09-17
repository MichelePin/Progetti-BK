<%*
/*
  Templater: create a standardized todo linked to the current file/project.

  Behavior:
  - Reads frontmatter `project` from the active file if present.
  - Prompts for: description, project (if not present), area, priority/difficulty, and whether to append to a central inbox.
  - Inserts task at cursor in current file by default; if appendToInbox is true, it appends to `Inbox/Ordine di trasferimento.md` (adjustable).
  - Task contains structured metadata lines (project::, area::, type:: task, status:: todo, difficulty::).
*/

const fm = await tp.frontmatter.get();
let project = fm && (fm.project || fm.Progetto || fm.Project);
if(!project){
  project = await tp.system.prompt("Project (leave blank to skip)");
}

const desc = await tp.system.prompt("Task description (short)");
if(!desc || desc.trim()===""){
  tR = "Cancelled: no description provided.";
} else {
  const area = await tp.system.prompt("Area (e.g. backend, frontend, docs)", "general");
  const difficulty = await tp.system.suggester(["bassa","media","alta"], ["bassa","media","alta"], true, "Difficulty? (choose or type)");
  const appendChoice = await tp.system.suggester(["Insert here","Append to Inbox"], ["insert","append"], true, "Where to put the task?");

  const filePath = tp.file.path(true);
  const fileLink = `[[${filePath}]]`;
  const projectPart = project && project.trim() !== "" ? `\n  project:: ${project.trim()}` : "";
  const areaPart = area && area.trim() !== "" ? `\n  area:: ${area.trim()}` : "";
  const diffPart = difficulty && difficulty.trim() !== "" ? `\n  difficulty:: ${difficulty.trim()}` : "";

  const taskLines = `- [ ] ${desc.trim()} #task\n  type:: task${projectPart}${areaPart}${diffPart}\n  status:: todo\n  source:: ${fileLink}`;

  if(appendChoice === "append"){
    const inbox = "Inbox/Ordine di trasferimento.md";
    let contentToAppend = "\n" + taskLines + "\n";
    if(!(await app.vault.adapter.exists(inbox))){
      await app.vault.create(inbox, `# Inbox\n\n`);
    }
    const file = await app.vault.read(await app.vault.getAbstractFileByPath(inbox));
    await app.vault.modify(await app.vault.getAbstractFileByPath(inbox), file + contentToAppend);
    tR = `Appended to ${inbox}`;
  } else {
    await tp.file.cursor.insert(taskLines + "\n");
    tR = `Inserted task in current file`;
  }
}
%>
