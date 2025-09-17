# 📊 Dashboard: WSpace

> Tutti i documenti relativi al progetto  WSpace, ordinati per tipo e data.

---

##  Code Files


```dataview

TABLE  Progetto, Linguaggio, Repo

FROM ""
WHERE Tipo = "Code-File" AND Progetto = "WSpace" AND Linguaggio = "CSharp"
SORT date DESC
```

##  Documenti di Analisi 

```dataview
TABLE file.link AS "Visualizza", Versione
FROM ""
WHERE Tipo = "Documento-Analisi" AND Progetto = "WSpace"
SORT date DESC
```

## Tabelle

```dataview

TABLE  Progetto, Linguaggio, Repo

FROM ""
WHERE Tipo = "Code-File" AND Progetto = "WSpace" AND Linguaggio = "SQL"
SORT date DESC
```

## Ultimi Sviluppi 
```dataview
TABLE  Progetto, Repo, Argomento

FROM ""
WHERE Tipo = "Rapportino" AND Progetto = "WSpace"
SORT date DESC
```

```dataview
TABLE feature, topic, time, date, file.link AS "Visualizza"
FROM ""
WHERE type = "Verbale" AND project = "WSpace"
SORT date DESC
```

