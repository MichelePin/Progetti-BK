<%*
/*
  Templater JS: Create a markdown todo linked to the current file and project metadata.

  Behavior:
  - Reads frontmatter `project` (or `Project`) from the current file.
  - Prompts for task description if not provided.
  - Inserts a markdown task at the cursor in the current file by default.
  - The task includes a `project::ProjectName` field and a link to the source file.

  Usage:
  - Open the file you want to create a task for (the source file).
  - Run this template via Templater: Insert template -> `Create todo linked to project.md`.
  - Provide a short task description when prompted.
*/

// get frontmatter project
const fm = tp.frontmatter;
let project = undefined;
try{
  const front = await tp.frontmatter.get();
  project = front && (front.project || front.Project || front.progetto || front.Progetto);
}catch(e){/* ignore */}

if(!project){
  project = await tp.system.prompt("Project name (leave blank to skip)");
}

const desc = await tp.system.prompt("Task description (short)");
if(!desc || desc.trim()===""){
  tR = "Cancelled: no description provided.";
} else {
  // build task line
  const filePath = tp.file.path(true); // full path relative to vault
  const fileLink = "[[" + filePath + "]]";
  const projectPart = project && project.trim() !== "" ? ` project::${project.trim()}` : "";
  const taskLine = `- [ ] ${desc.trim()} #task${projectPart} ${fileLink}`;

  // insert at cursor position in current file
  await tp.file.cursor.insert(taskLine + "\n");
  tR = `Inserted task: ${taskLine}`;
}
%>
