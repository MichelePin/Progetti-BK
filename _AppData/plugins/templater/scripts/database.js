projects = ["WSpace", "WEC", "DBK_Suite", "eDoor", "Globale", "Varie"];
version = "2.60.3";
olderVersions = ["2.60.2", "2.60.0"];
programmingLanguages = ["TypeScript", "CSharp", "SQL"]

function getDatabase(type){
    if (type === "projects") {
        return projects;
    } else if (type === "version") {
        return version;
    } else if (type === "olderVersions") {
        return olderVersions;
    } else if (type === "programmingLanguages") {
        return programmingLanguages;
    } else {
        throw new Error("Invalid type specified");
    }
}

module.exports = 
    getDatabase;
