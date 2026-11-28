*&---------------------------------------------------------------------*
*& Include ZPRC_TRANSLATE_DE_DICT5
*& Iteration 11 (18.11.2026): simulation runs - messages, field labels,
*& new objects in core, demo and test repository; consistency check demo;
*& remaining texts of the run of 18.11. (NO_ENTRY)
*& Iteration 12 (19.11.2026): Standard ABAP jobs (job scheduler, test
*& run job), tools repository
*& Iteration 13 (19.11.2026): job log and authorization of the run job,
*& helper reports
*& Iteration 14 (27.11.2026): delivery rework (Fiori packages, manual
*& content, calculation classes), demo action parameter, tools (git
*& repair report with selection texts, findings table)
*& Iteration 15 (28.11.2026): release 0.2.0 - completed English texts
*& (field labels, test data elements, selection texts, job texts,
*& authorization objects)
*&---------------------------------------------------------------------*
    " messages ZPRC_PROCESS_MESSAGE 026-028 (73 characters at most)
    add( en = `Process class &1 does not allow simulation; nothing was processed`
         de = `Prozessklasse &1 erlaubt keine Simulation; nichts wurde verarbeitet` ).
    add( en = `Simulation needs a process with the states START and FINISHED only (&1)`
         de = `Simulation nur für Prozesse mit den Zuständen START und FINISHED (&1)` ).
    add( en = `Running in simulation mode: nothing was saved`
         de = `Simulationsmodus: nichts wurde gespeichert` ).
    " field labels (DDLX ZI_PRC_Run, ZI_PRC_ProcessedObject, demo action parameter)
    add( en = `Simulation` de = `Simulation` ).
    " descriptions of the new objects
    add( en = `Run - Simulation flag` de = `Run - Kennzeichen Simulation` ).
    add( en = `ABAP-PRC: Rule for simulation runs` de = `ABAP-PRC: Regel für Simulationsläufe` ).
    add( en = `PRC Test: Process that allows simulation` de = `PRC Test: Prozess, der Simulation erlaubt` ).
    add( en = `PRC Test: Simulation runs` de = `PRC Test: Simulationsläufe` ).

    " consistency check demo: messages ZPRC_DEMO_CONS_CHECK (73 characters at most)
    add( en = `Item &1: equipment &2 is already in released contract &3`
         de = `Position &1: Equipment &2 ist bereits im freigegebenen Vertrag &3` ).
    add( en = `Service contract &1 released` de = `Servicevertrag &1 freigegeben` ).
    add( en = `Service contract &1 not released: resolve the findings first`
         de = `Servicevertrag &1 nicht freigegeben: zuerst die Befunde beheben` ).
    add( en = `Consistency check of service contract &1 scheduled`
         de = `Konsistenzprüfung von Servicevertrag &1 eingeplant` ).
    add( en = `Service contract &1 is already released` de = `Servicevertrag &1 ist bereits freigegeben` ).
    add( en = `Service contract &1: &2 finding(s) - correct them and check again`
         de = `Servicevertrag &1: &2 Befund(e) - korrigieren und erneut prüfen` ).
    add( en = `Consistency check run for all unreleased service contracts started`
         de = `Konsistenzprüfung aller nicht freigegebenen Serviceverträge gestartet` ).
    " consistency check demo: actions, classes, job catalog and template
    add( en = `Check` de = `Prüfen` ).
    add( en = `Release` de = `Freigeben` ).
    add( en = `Check All Unreleased` de = `Alle nicht freigegebenen prüfen` ).
    add( en = `Demo: Consistency rule of a service contract` de = `Demo: Konsistenzregel eines Servicevertrags` ).
    add( en = `Demo: Consistency check run of unreleased contracts` de = `Demo: Konsistenzlauf nicht freigegebener Verträge` ).
    add( en = `Demo: Consistency check of a service contract` de = `Demo: Konsistenzprüfung eines Servicevertrags` ).
    add( en = `Demo: Trigger the consistency check of contracts` de = `Demo: Konsistenzprüfung von Verträgen anstoßen` ).
    add( en = `ABAP-PRC Demo: Consistency Check` de = `ABAP-PRC Demo: Konsistenzprüfung` ).

    " English originals corrected by ZPRC_FIX_EN_TEXTS and in ADT (18.11.)
    add( en = `Demo: Equipment` de = `Demo: Equipment` ).
    add( en = `PRC Test: BO for bgPF (adjust_numbers)` de = `PRC Test: BO für bgPF (adjust_numbers)` ).
    " before the correction (if ZPRC_FIX_EN_TEXTS has not run yet)
    add( en = `Denmo: Equipment` de = `Demo: Equipment` ).
    add( en = `PRC Test: BO bgPF aus adjust_numbers` de = `PRC Test: BO für bgPF aus adjust_numbers` ).
    add( en = `PRC Test: BO fuer bgPF aus adjust_numbers` de = `PRC Test: BO für bgPF aus adjust_numbers` ).
    add( en = `PRC Test: RAP BO Fehlerszenarien` de = `PRC Test: RAP-BO-Fehlerszenarien` ).

    " Standard ABAP jobs (19.11.): job scheduler, test run job with catalog and template
    add( en = `ABAP-PRC: Schedules app. jobs of both language versions`
         de = `ABAP-PRC: Plant Anwendungsjobs beider Sprachversionen ein` ).
    add( en = `PRC Test: Run job in Standard ABAP` de = `PRC Test: Run-Job in Standard ABAP` ).
    add( en = `ABAP-PRC Test: Run job in Standard ABAP` de = `ABAP-PRC Test: Run-Job in Standard ABAP` ).
    add( en = `ABAP-PRC Test: Run Job in Standard ABAP` de = `ABAP-PRC Test: Run-Job in Standard ABAP` ).
    " tools repository (19.11.)
    add( en = `ABAP-PRC: Internal tools (private repository)` de = `ABAP-PRC: Interne Werkzeuge (privates Repository)` ).
    add( en = `ABAP-PRC Tools: Translation EN -> DE (Standard ABAP)`
         de = `ABAP-PRC Tools: Übersetzung EN -> DE (Standard ABAP)` ).
    add( en = `ABAP-PRC: Results of translation report` de = `ABAP-PRC: Ergebnisse des Übersetzungsreports` ).
    add( en = `ABAP-PRC: Translate short texts EN -> DE via LXE` de = `ABAP-PRC: Kurztexte EN -> DE über LXE übersetzen` ).
    add( en = `ABAP-PRC Tools: Test and demo data` de = `ABAP-PRC Tools: Test- und Demodaten` ).
    add( en = `ABAP-PRC Tools: Delete all test and demo data` de = `ABAP-PRC Tools: Alle Test- und Demodaten löschen` ).

    " job log and authorization of the run job (19.11.): messages ZPRC_RUN 012-014 (73 characters at most)
    add( en = `Run &1 of application &2: &3 objects selected`
         de = `Run &1 der Anwendung &2: &3 Objekte selektiert` ).
    add( en = `Run &1 finished` de = `Run &1 beendet` ).
    add( en = `No authorization to start runs of application &1`
         de = `Keine Berechtigung, Runs der Anwendung &1 zu starten` ).
    " helper reports of the tools repository (19.11.)
    add( en = `Copy package attributes from template package (TDEVC)`
         de = `Paketattribute aus Vorlagepaket kopieren (TDEVC)` ).
    add( en = `ABAP-PRC: Set ABAP language version of packages (TDEVC)`
         de = `ABAP-PRC: ABAP-Sprachversion von Paketen setzen (TDEVC)` ).

    " delivery rework (27.11.): calculation class, Fiori packages, manual content
    add( en = `ABAP-PRC: Link to the processed object (calc. exit)`
         de = `ABAP-PRC: Link zum verarbeiteten Objekt (Berechnungs-Exit)` ).
    add( en = `ABAP-PRC: Message text in the logon language (calc. exit)`
         de = `ABAP-PRC: Meldungstext in Anmeldesprache (Berechnungs-Exit)` ).
    add( en = `ABAP-PRC: Fiori apps (BSP) - ABAP Cloud` de = `ABAP-PRC: Fiori-Apps (BSP) - ABAP Cloud` ).
    add( en = `ABAP-PRC Demo: Fiori apps (BSP) - ABAP Cloud` de = `ABAP-PRC Demo: Fiori-Apps (BSP) - ABAP Cloud` ).
    add( en = `ABAP-PRC: Content installed manually (not in a repository)`
         de = `ABAP-PRC: Manuell installierte Inhalte (nicht im Repository)` ).
    add( en = `ABAP-PRC: Content installed manually - Standard ABAP`
         de = `ABAP-PRC: Manuell installierte Inhalte - Standard ABAP` ).
    " same packages with the original (German) description of 27.11. until renamed
    add( en = `ABAP-PRC: Fiori-Apps (BSP) - ABAP Cloud` de = `ABAP-PRC: Fiori-Apps (BSP) - ABAP Cloud` ).
    add( en = `ABAP-PRC Demo: Fiori-Apps (BSP) - ABAP Cloud` de = `ABAP-PRC Demo: Fiori-Apps (BSP) - ABAP Cloud` ).
    add( en = `ABAP-PRC: Manuell zu installierende Inhalte (nicht im Repo)`
         de = `ABAP-PRC: Manuell installierte Inhalte (nicht im Repository)` ).
    add( en = `ABAP-PRC: Manuell zu installierende Inhalte - Standard ABAP`
         de = `ABAP-PRC: Manuell installierte Inhalte - Standard ABAP` ).
    " demo action parameter of the consistency check (ZA_PRC_DEMO_CHECKPARAMSELOPT)
    add( en = `Action parameter to initiate the check run` de = `Aktionsparameter zum Starten des Prüflaufs` ).
    add( en = `Parameter to initiate the check run` de = `Parameter zum Starten des Prüflaufs` ).
    " tools: git repair, cleanup report
    add( en = `ABAP-PRC Tools: Git repair (inconsistencies after abapGit)`
         de = `ABAP-PRC Tools: Git-Reparatur (Inkonsistenzen nach abapGit)` ).
    add( en = `ABAP-PRC Tools: Git-Repair (Inkonsistenzen nach abapGit)`
         de = `ABAP-PRC Tools: Git-Reparatur (Inkonsistenzen nach abapGit)` ).
    add( en = `ABAP-PRC Tools: Clean up orphaned objects` de = `ABAP-PRC Tools: Verwaiste Objekte aufräumen` ).
    add( en = `ABAP-PRC Tools: verwaiste Objekte aufraeumen` de = `ABAP-PRC Tools: Verwaiste Objekte aufräumen` ).
    add( en = `ABAP-PRC: Findings of the git repair report` de = `ABAP-PRC: Befunde des Git-Reparatur-Reports` ).
    " git repair: text symbols and selection texts (30 characters at most)
    add( en = `Object set` de = `Objektmenge` ).
    add( en = `Git problems` de = `Git-Probleme` ).
    add( en = `Follow-up tasks and tool` de = `Nacharbeiten und Werkzeug` ).
    add( en = `Repair` de = `Bereinigung` ).
    add( en = `Packages (incl. subpackages)` de = `Pakete (inkl. Unterpakete)` ).
    add( en = `Name patterns` de = `Namensmuster` ).
    add( en = `TADIR entry without object` de = `TADIR-Eintrag ohne Objekt` ).
    add( en = `Source without TADIR entry` de = `Quelle ohne TADIR-Eintrag` ).
    add( en = `Object without package` de = `Objekt ohne Paket` ).
    add( en = `Language version '-'` de = `Sprachversion '-'` ).
    add( en = `Worklist entry without TADIR` de = `Inaktiv-Eintrag ohne TADIR` ).
    add( en = `Service group without hash` de = `Service-Gruppe ohne Hash` ).
    add( en = `Lock without request entry` de = `Sperre ohne Auftragseintrag` ).
    add( en = `Binding not activated` de = `Binding nicht aktiviert` ).
    add( en = `Service group not published` de = `Gruppe nicht veröffentlicht` ).
    add( en = `No SU24 default values` de = `Keine SU24-Vorschlagswerte` ).
    add( en = `Tool: CDS/RAP to worklist` de = `Werkzeug: CDS/RAP in Liste` ).
    add( en = `Target package (NO_PACKAGE)` de = `Zielpaket (NO_PACKAGE)` ).
    add( en = `Language version (LANG_DASH)` de = `Sprachversion (LANG_DASH)` ).
    add( en = `Repair all rows` de = `Alle Zeilen bereinigen` ).
    add( en = `Test run` de = `Testlauf` ).
    add( en = `No ALV (log only)` de = `Ohne ALV (nur Protokoll)` ).
    " launchpad app descriptor items generated from the manifests (not in a repository)
    add( en = `An SAP Fiori application.` de = `Eine SAP-Fiori-Anwendung.` ).
    add( en = `Show and manage` de = `Anzeigen und verwalten` ).
    add( en = `Process Recovery Center` de = `Process Recovery Center` ).

    " release 0.2.0 (28.11.): field labels of the message severity (10/20/55 characters at most)
    add( en = `Severity` de = `Schweregrad` de_short = `Schweregr.` ).
    add( en = `Severity Code` de = `Schweregrad-Code` ).
    add( en = `Sev. Code` de = `Schw.-Code` ).
    " data elements of the manual test T3 (test repository)
    add( en = `ABAP-PRC Test: syntax error in handler (manual test T3)`
         de = `ABAP-PRC Test: Syntaxfehler im Handler (manueller Test T3)` ).
    add( en = `ABAP-PRC Test: syntax error in process (manual test T3)`
         de = `ABAP-PRC Test: Syntaxfehler im Prozess (manueller Test T3)` ).
    add( en = `Syntax Handler` de = `Syntax-Handler` ).
    add( en = `Syntax Process` de = `Syntax-Prozess` ).
    add( en = `Test Syntax Error Handler` de = `Test Syntaxfehler-Handler` ).
    add( en = `Test Syntax Error Process` de = `Test Syntaxfehler-Prozess` ).
    add( en = `Handler` de = `Handler` ).
    " selection texts of ZPRC_TRANSLATE_DE (30 characters at most)
    add( en = `No ALV output` de = `Keine ALV-Ausgabe` ).
    add( en = `Overwrite existing texts` de = `Vorhandene Texte überschreiben` ).
    add( en = `Source language` de = `Quellsprache` ).
    add( en = `Target language` de = `Zielsprache` ).
    add( en = `Test mode` de = `Testmodus` ).
    add( en = `Root package` de = `Wurzelpaket` ).
    add( en = `Object type` de = `Objekttyp` ).
    " job catalog entries and templates with the area prefix (same text in both)
    add( en = `ABAP-PRC Demo: Service Contract Adjustment Run`
         de = `ABAP-PRC Demo: Anpassungslauf für Serviceverträge` ).
    add( en = `ABAP-PRC Demo: BAPIs in Jobs - without ABAP-PRC`
         de = `ABAP-PRC Demo: BAPIs in Jobs - ohne ABAP-PRC` ).
    add( en = `ABAP-PRC Demo: BAPIs in Jobs - with ABAP-PRC`
         de = `ABAP-PRC Demo: BAPIs in Jobs - mit ABAP-PRC` ).
    " authorization objects
    add( en = `ABAP-PRC: Process` de = `ABAP-PRC: Prozess` ).
    add( en = `ABAP-PRC: Run Application` de = `ABAP-PRC: Run-Anwendung` ).
    " demo packages in Standard ABAP with the prefix ABAP-PRC Demo (60 characters at most)
    add( en = `ABAP-PRC Demo: BAPI & Jobs - BAPIs, tables, messages`
         de = `ABAP-PRC Demo: BAPI & Jobs - BAPIs, Tabellen, Meldungen` ).
    add( en = `ABAP-PRC Demo: BAPI & RAP - BAPIs, tables, messages`
         de = `ABAP-PRC Demo: BAPI & RAP - BAPIs, Tabellen, Meldungen` ).
    add( en = `ABAP-PRC Demo: BAPI & RAP 2 - BAPI as persistence`
         de = `ABAP-PRC Demo: BAPI & RAP 2 - BAPI als Persistenz` ).
    add( en = `ABAP-PRC Demo: BAPI & RAP 3 - Post-processing in same LUW`
         de = `ABAP-PRC Demo: BAPI & RAP 3 - Folgebeleg in derselben LUW` ).
