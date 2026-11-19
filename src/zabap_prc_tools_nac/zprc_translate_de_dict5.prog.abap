*&---------------------------------------------------------------------*
*& Include ZPRC_TRANSLATE_DE_DICT5
*& Iteration 11 (18.11.2026): simulation runs - messages, field labels,
*& new objects in core, demo and test repository; consistency check demo;
*& remaining texts of the run of 18.11. (NO_ENTRY)
*& Iteration 12 (19.11.2026): Standard ABAP jobs (job scheduler, test
*& run job), tools repository
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
