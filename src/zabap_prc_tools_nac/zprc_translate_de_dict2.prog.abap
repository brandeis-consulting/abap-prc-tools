*&---------------------------------------------------------------------*
*& Include ZPRC_TRANSLATE_DE_DICT2
*& Iteration 2: prefix rules, short variants, object descriptions.
*& add_prefix( ): English prefix -> German prefix, rest is kept
*& set_short( ):  variant used if the German text exceeds the max. length
*&---------------------------------------------------------------------*
    add_prefix( en = `DCL for ` de = `DCL für ` ).
    add_prefix( en = `Behavior Implementation for ` de = `Verhaltensimplementierung für ` ).

    set_short( en = `Message Text` de_short = `Nachr.text` ).
    set_short( en = `Message` de_short = `Nachr.` ).

    add( en = `Business Logic for Run Business Object` de = `Geschäftslogik für das Business-Objekt Lauf` ).
    add( en = `ABAP-PRC: Authorization checks for object ZPRC_PROC` de = `ABAP-PRC: Berechtigungsprüfungen für Objekt ZPRC_PROC` ).
    add( en = `ABAP-PRC: Authorization checks for object ZPRC_RUN` de = `ABAP-PRC: Berechtigungsprüfungen für Objekt ZPRC_RUN` ).
    add( en = `BGPF Implementation for the PRC` de = `bgPF-Implementierung für das PRC` ).
    add( en = `ABAP-PRC: Writes the PRC persistence` de = `ABAP-PRC: Schreibt die PRC-Persistenz` ).
    add( en = `ABAP-PRC: Finds the short dump of an aborted step` de = `ABAP-PRC: Findet den Kurzdump eines abgebrochenen Schritts` ).
    add( en = `ABAP-PRC: Error notification job` de = `ABAP-PRC: Job für Fehlerbenachrichtigung` ).
    add( en = `ABAP-PRC: Package of objects running in a session of its own` de = `ABAP-PRC: Objektpaket in eigener Session` ).
    add( en = `ABAP-PRC: List layer - parallel packages` de = `ABAP-PRC: Listenschicht - parallele Pakete` ).
    add( en = `ABAP-PRC: List layer - grouping and queue` de = `ABAP-PRC: Listenschicht - Gruppierung und Queue` ).
    add( en = `ABAP-PRC: List layer - selection` de = `ABAP-PRC: Listenschicht - Selektion` ).
    add( en = `Standard implementation of ZIF_PRC_MESSAGE_HANDLER` de = `Standardimplementierung von ZIF_PRC_MESSAGE_HANDLER` ).
    add( en = `Converts RAP and BAPI responses into SYMSG` de = `Konvertiert RAP- und BAPI-Antworten in SYMSG` ).
    add( en = `ABAP-PRC: Message text in the logon language (calc. exit)` de = `ABAP-PRC: Nachrichtentext in Anmeldesprache (Calc. Exit)` ).
    add( en = `ABAP-PRC: Notification format and helpers` de = `ABAP-PRC: Benachrichtigungsformat und Hilfsmethoden` ).
    add( en = `ABAP-PRC: Notification channel mail` de = `ABAP-PRC: Benachrichtigungskanal Mail` ).
    add( en = `ABAP-PRC: Process error notification` de = `ABAP-PRC: Prozess Fehlerbenachrichtigung` ).
    add( en = `ABAP-PRC: Process run completed notification` de = `ABAP-PRC: Prozess Benachrichtigung Lauf beendet` ).
    add( en = `ABAP-PRC: Notification - send step` de = `ABAP-PRC: Benachrichtigung - Sendeschritt` ).
    add( en = `ABAP-PRC: Lock on a processed object` de = `ABAP-PRC: Sperre auf ein verarbeitetes Objekt` ).
    add( en = `ABAP-PRC: Object level - run bookkeeping` de = `ABAP-PRC: Objektebene - Fortschreibung des Laufs` ).
    add( en = `ABAP-PRC: Object level - step loop` de = `ABAP-PRC: Objektebene - Schrittschleife` ).
    add( en = `Processing API` de = `Verarbeitungs-API` ).
    add( en = `ABAP-PRC: Processing engine` de = `ABAP-PRC: Verarbeitungs-Engine` ).
    add( en = `Loads process classes without short dumps` de = `Lädt Prozessklassen ohne Kurzdumps` ).
    add( en = `Calculation of the processed steps` de = `Berechnung der verarbeiteten Schritte` ).
    add( en = `Application job implementation class` de = `Implementierungsklasse für Anwendungsjob` ).
    add( en = `Run initiator` de = `Lauf-Initiator` ).
    add( en = `Job abstract class for Run pattern` de = `Abstrakte Jobklasse für das RUN-Muster` ).
    add( en = `ABAP-PRC: Step layer 1 - core` de = `ABAP-PRC: Schrittschicht 1 - Kern` ).
    add( en = `ABAP-PRC: Step layer 2 - simulation` de = `ABAP-PRC: Schrittschicht 2 - Simulation` ).
    add( en = `ABAP-PRC: Step layer 3 - write result` de = `ABAP-PRC: Schrittschicht 3 - Ergebnis schreiben` ).
    add( en = `ABAP-PRC: Step layer 4 - commit` de = `ABAP-PRC: Schrittschicht 4 - Commit` ).
    add( en = `ABAP-PRC: Step layer 5 - expected errors` de = `ABAP-PRC: Schrittschicht 5 - erwartete Fehler` ).
    add( en = `ABAP-PRC: Step layer 6 - unexpected errors` de = `ABAP-PRC: Schrittschicht 6 - unerwartete Fehler` ).
    add( en = `ABAP-PRC: Step layer 7 - lock` de = `ABAP-PRC: Schrittschicht 7 - Sperre` ).
    add( en = `ABAP-PRC: Step layer 8 - isolation` de = `ABAP-PRC: Schrittschicht 8 - Isolation` ).
    add( en = `ABAP-PRC: Step running in a session of its own` de = `ABAP-PRC: Schritt in eigener Session` ).
    add( en = `ABAP-PRC: Step layer 9 - event` de = `ABAP-PRC: Schrittschicht 9 - Event` ).
    add( en = `ABAP-PRC: Builds the layers of the step level` de = `ABAP-PRC: Baut die Schichten der Schrittebene auf` ).
    add( en = `ABAP-PRC: Step layer - application log` de = `ABAP-PRC: Schrittschicht - Anwendungsprotokoll` ).
    add( en = `ABAP-PRC: Writes one step of the step level` de = `ABAP-PRC: Schreibt einen Schritt der Schrittebene` ).
    add( en = `ABAP-PRC: System URL from the ICM (Standard ABAP)` de = `ABAP-PRC: System-URL aus dem ICM (Standard ABAP)` ).
    add( en = `Base class for transition handlers` de = `Basisklasse für Transition-Handler` ).
    add( en = `ABAP-PRC: Local update task (Standard ABAP, C1)` de = `ABAP-PRC: Lokale Verbuchung (Standard ABAP, C1)` ).
    add( en = `ABAP-PRC: Process definition violated by the process class` de = `ABAP-PRC: Prozessdefinition durch Prozessklasse verletzt` ).
    add( en = `Unit of work failed - signal only, carries no data` de = `Unit of Work fehlgeschlagen - nur Signal, ohne Daten` ).
    add( en = `Parameter to create a Processed Object` de = `Parameter zum Anlegen eines verarbeiteten Objekts` ).
    add( en = `Parameter to initiate the run` de = `Parameter zum Starten des Laufs` ).
    add( en = `Result for Action triggering Run` de = `Ergebnis der Aktion zum Auslösen eines Laufs` ).
    add( en = `Processed Message` de = `Verarbeitete Nachricht` ).
    add( en = `Run` de = `Lauf` ).
    add( en = `Runs` de = `Läufe` ).
    add( en = `Application Name Value Help` de = `Wertehilfe Anwendungsname` ).
    add( en = `Header Messages of All Steps` de = `Kopfnachrichten aller Schritte` ).
    add( en = `Header Messages Grouped` de = `Kopfnachrichten gruppiert` ).
    add( en = `Header Message of the Latest Step` de = `Kopfnachricht des letzten Schritts` ).
    add( en = `Process Object Aggregates` de = `Aggregate der verarbeiteten Objekte` ).
    add( en = `Available application Names` de = `Verfügbare Anwendungsnamen` ).
    add( en = `Available States` de = `Verfügbare Zustände` ).
    add( en = `Users of processed objects` de = `Benutzer verarbeiteter Objekte` ).
    add( en = `Parameter for run` de = `Parameter für den Lauf` ).
    add( en = `Run Progress and Statistics` de = `Fortschritt und Statistik des Laufs` ).
    add( en = `ABAP-PRC: Core - ABAP Cloud` de = `ABAP-PRC: Kern - ABAP Cloud` ).
    add( en = `ABAP-PRC: Authorizations` de = `ABAP-PRC: Berechtigungen` ).
    add( en = `ABAP-PRC: Event side effects (2025 and BTP only)` de = `ABAP-PRC: Event-Side-Effects (nur 2025 und BTP)` ).
    add( en = `ABAP-PRC: Fiori apps and launchpad content (on-premise)` de = `ABAP-PRC: Fiori-Apps und Launchpad-Inhalte (On-Premise)` ).
    add( en = `ABAP-PRC: Message handler` de = `ABAP-PRC: Message-Handler` ).
    add( en = `ABAP-PRC: Core - Standard ABAP (on-premise only)` de = `ABAP-PRC: Kern - Standard ABAP (nur On-Premise)` ).
    add( en = `ABAP-PRC: Notifications (mail, channel BAdI)` de = `ABAP-PRC: Benachrichtigungen (Mail, Kanal-BAdI)` ).
    add( en = `ABAP-PRC: Notifications - Standard ABAP (system URL)` de = `ABAP-PRC: Benachrichtigungen - Standard ABAP (System-URL)` ).
    add( en = `ABAP-PRC: Messages of processed objects (message app)` de = `ABAP-PRC: Nachrichten verarb. Objekte (Nachrichten-App)` ).
    add( en = `ABAP-PRC: Processed objects (BO and app)` de = `ABAP-PRC: Verarbeitete Objekte (BO und App)` ).
    add( en = `ABAP-PRC: Processing API (create and process objects)` de = `ABAP-PRC: Verarbeitungs-API (Objekte anlegen/verarbeiten)` ).
    add( en = `ABAP-PRC: Processing engine (steps, isolation, log)` de = `ABAP-PRC: Verarbeitungs-Engine (Schritte, Isolation, Log)` ).
    add( en = `ABAP-PRC: Processing engine - Standard ABAP (dump finder)` de = `ABAP-PRC: Verarb.-Engine - Standard ABAP (Dump-Finder)` ).
    add( en = `ABAP-PRC: Process API (process, transition handler)` de = `ABAP-PRC: Prozess-API (Prozess, Transition-Handler)` ).
    add( en = `ABAP-PRC: Retry job` de = `ABAP-PRC: Wiederholungsjob` ).
    add( en = `ABAP-PRC: Run API (base class for run jobs)` de = `ABAP-PRC: Lauf-API (Basisklasse für Lauf-Jobs)` ).
    add( en = `ABAP-PRC: Run BO and app` de = `ABAP-PRC: Lauf-BO und App` ).
    add( en = `ABAP-PRC: Core` de = `ABAP-PRC: Kern` ).
    add( en = `Send notifications for errors occured during processing` de = `Benachrichtigungen für Fehler bei der Verarbeitung senden` ).
    add( en = `Mail. Fiori Notificaiton,...?` de = `Mail, Fiori-Benachrichtigung, ...?` ).
    add( en = `ABAP Processing Center Notifications` de = `ABAP Processing Center Benachrichtigungen` ).
    add( en = `Collects messages and decides on failure` de = `Sammelt Nachrichten und entscheidet über Fehlschlag` ).
    add( en = `ABAP-PRC: Notification channel` de = `ABAP-PRC: Benachrichtigungskanal` ).
    add( en = `A process: its state graph and its transitions` de = `Ein Prozess: sein Zustandsgraph und seine Übergänge` ).
    add( en = `Raise entity event` de = `Entity-Event auslösen` ).
    add( en = `ABAP-PRC: Types of the processing engine` de = `ABAP-PRC: Typen der Verarbeitungs-Engine` ).
    add( en = `ABAP-PRC: List level - list of objects` de = `ABAP-PRC: Listenebene - Liste von Objekten` ).
    add( en = `ABAP-PRC: Object level - one object` de = `ABAP-PRC: Objektebene - ein Objekt` ).
    add( en = `ABAP-PRC: Step level - one transition` de = `ABAP-PRC: Schrittebene - ein Übergang` ).
    add( en = `Run interface` de = `Lauf-Interface` ).
    add( en = `ABAP-PRC: System URL for links in mails` de = `ABAP-PRC: System-URL für Links in Mails` ).
    add( en = `Executes one transition as a unit of work` de = `Führt einen Übergang als Unit of Work aus` ).
    add( en = `ABAP-PRC: Local update task` de = `ABAP-PRC: Lokale Verbuchung` ).
    add( en = `Deployed with SAP Fiori tools` de = `Deployed mit SAP Fiori Tools` ).
    add( en = `Processed Objects app` de = `App Verarbeitete Objekte` ).
    add( en = `ABAP Processing Center - Processing Objects` de = `ABAP Processing Center - Verarbeitungsobjekte` ).

    " --- iteration 3
    add( en = `Schedules application jobs` de = `Plant Anwendungsjobs ein` ).
    add( en = `Test injection of the job scheduler` de = `Testinjektion des Job-Schedulers` ).
    add( en = `Mail, Fiori Notification,...?` de = `Mail, Fiori-Benachrichtigung, ...?` ).

    " --- iteration 4: launchpad app descriptors (UIAD)
    add( en = `Processing Center` de = `Processing Center` ).
    add( en = `ABAP Processing Center - Processed Message` de = `ABAP Processing Center - Verarbeitete Nachricht` ).
    add( en = `ABAP Processing Center - Processed Messages` de = `ABAP Processing Center - Verarbeitete Nachrichten` ).
    add( en = `ABAP Processing Center - Processed Object` de = `ABAP Processing Center - Verarbeitetes Objekt` ).
    add( en = `ABAP Processing Center - Processed Objects` de = `ABAP Processing Center - Verarbeitete Objekte` ).
    add( en = `ABAP Processing Center - Run` de = `ABAP Processing Center - Lauf` ).
    add( en = `ABAP Processing Center - Runs` de = `ABAP Processing Center - Läufe` ).

    " --- iteration 5: clean-up job (catalog and template)
    add( en = `ABAP Processing Center: Clean-up Job for Runs and Proc. Obj.` de = `ABAP Processing Center: Bereinigungsjob für Läufe und verarb. Obj.` ).
    add( en = `ABAP Processing Center: Cleanup job for old Runs, Proc. Obj.` de = `ABAP Processing Center: Bereinigungsjob für alte Läufe, verarb. Obj.` ).

    " --- iteration 6: corrected English source texts
    add( en = `Payload (e.g. JSON)` de = `Payload (z. B. JSON)` ).
    add( en = `Value Help for available States` de = `Wertehilfe für verfügbare Zustände` ).
    add( en = `Send notifications for errors occurred during processing` de = `Benachrichtigungen für Fehler bei der Verarbeitung senden` ).

    " --- iteration 7 (11.11.2026): processing API, testability, step header
    add( en = `Step failed without error message` de = `Schritt ohne Fehlermeldung fehlgeschlagen` ).
    add( en = `Step processed successfully` de = `Schritt erfolgreich verarbeitet` ).
    add( en = `Program error: success message &1 &2 has type &3 (allowed: S, I, W)` de = `Programmfehler: Erfolgsmeldung &1 &2 hat Typ &3 (erlaubt: S, I, W)` ).
    add( en = `Schedules processing via bgPF` de = `Plant die Verarbeitung per bgPF ein` ).
    add( en = `Test injection of the bgPF scheduler` de = `Testinjektion des bgPF-Schedulers` ).
    add( en = `ABAP-PRC: Step header` de = `ABAP-PRC: Kopfnachricht des Schritts` ).
    add( en = `Test base for transition handlers` de = `Testbasis für Transition-Handler` ).
    add( en = `Message handler for tests` de = `Message-Handler für Tests` ).
    add( en = `Cleanup job (data retention)` de = `Bereinigungsjob (Datenhaltung)` ).
