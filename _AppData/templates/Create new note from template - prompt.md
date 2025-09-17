<%*
/*
  Templater JS helper: prompts for a template path, filename and folder,
  creates the new note from the selected template and opens it.

  Usage:
  - Install and enable the Templater plugin in Obsidian.
  - Place this file in your Templater templates folder (it's already in _AppData/templates).
  - Run this template via the Command Palette > "Templater: Insert template" or assign a hotkey.

  Notes:
  - Provide the template path relative to the vault root. Example: `_AppData/templates/Documento Tecnico.md` or `Templates/Meeting.md`.
  - The created note will be opened automatically.
*/

// Ask for the template path
const templatePath = await tp.system.prompt("Template path (relative to vault). Example: _AppData/templates/Documento Tecnico.md");
if(!templatePath || templatePath.trim() === ""){
  tR = "Cancelled: no template path provided.";
} else {
  const tpl = tp.file.find_tfile(templatePath.trim());
  if(!tpl){
    tR = `Template not found: ${templatePath}`;
  } else {
    // Ask for filename
    const filename = await tp.system.prompt("Filename (without extension)");
    if(!filename || filename.trim() === ""){
      tR = "Cancelled: no filename provided.";
    } else {
      // Ask for destination folder (optional)
      const folder = await tp.system.prompt("Folder path (relative to vault root). Leave blank for vault root or use subfolder like 'WSpace/Documento Analisi'");
      const folderClean = folder && folder.trim() !== "" ? folder.trim().replace(/\\/g, '/') : "";
      const dest = (folderClean ? (folderClean.replace(/\/+$/,'') + '/') : '') + filename.trim() + '.md';

      // Create the new file from the chosen template and open it
      await tp.file.create_new(tpl, dest, true);
      tR = `Created and opened: ${dest}`;
    }
  }
}
%>
