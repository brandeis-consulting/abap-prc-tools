*&---------------------------------------------------------------------*
*& Report ZPRC_GIT_REPAIR
*&---------------------------------------------------------------------*
*& Git repair: finds inconsistencies left by abapGit pulls and open
*& follow-up tasks for a set of objects and repairs them by click.
*&
*& Object set: packages (incl. subpackages) OR name patterns. Defaults
*& for ABAP-PRC; reusable for other projects via variants. Name patterns
*& also work where there is no package (orphaned entries, sources
*& without TADIR, locks).
*&
*& Git problems (caused by partial or failed pulls):
*&  ORPHAN_TADIR  TADIR entry without object (SMIM without MIME folder,
*&                DCLS without source, package without TDEVC, ...)
*&  DRAFT_NOTADIR source without TADIR (e.g. MDE that ADT cannot delete)
*&  NO_PACKAGE    TADIR entry without valid package
*&  LANG_DASH     ABAP language version '-' (abapGit setting "Ignore")
*&  WORKLIST      entry in the inactive worklist without TADIR
*&  G4BA_NOHASH   service group from a table copy: no USOBHASH
*&  LOCK_ORPHAN   lock (TLOCK) without entry in the request
*& Follow-up tasks (after the installation):
*&  SRVB_NO_G4BA  service binding not activated (no service group)
*&  G4BA_NOPUBL   service group not published (/IWFND/V4_ADMIN)
*&  SU24_EMPTY    application registered, but no SU24 values
*& Tool:
*&  TO_WORKLIST   puts CDS/RAP objects into the inactive worklist so that
*&                one mass activation activates them (e.g. views that
*&                have errors but are not inactive)
*&
*& Development and test systems only. Action per row by click (test run
*& and confirmation first) or P_FIXALL for all rows.
*&
*& Findings log: every run replaces the content of table ZPRC_GIT_FINDING
*& (one row per finding: STATUS OPEN/HINT/TESTED/DONE/ERROR, KIND,
*& CATEGORY, object, package, FINDING = what is wrong and why it matters,
*& ACTION = the repair the report offers, OUTCOME = result of test run or
*& repair). The table can be evaluated by SQL, e.g. by an AI assistant.
*& P_NODISP runs without ALV (for SUBMIT from tests); P_FIXALL with
*& P_TEST = space repairs everything and logs the outcome.
*&---------------------------------------------------------------------*
REPORT zprc_git_repair.

TABLES: tadir, tdevc.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
  SELECT-OPTIONS s_root FOR tdevc-devclass NO INTERVALS.
  SELECT-OPTIONS s_pref FOR tadir-obj_name NO INTERVALS.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
  PARAMETERS: p_c1 AS CHECKBOX DEFAULT abap_true,   " ORPHAN_TADIR
              p_c2 AS CHECKBOX DEFAULT abap_true,   " DRAFT_NOTADIR
              p_c3 AS CHECKBOX DEFAULT abap_true,   " NO_PACKAGE
              p_c4 AS CHECKBOX DEFAULT abap_true,   " LANG_DASH
              p_c5 AS CHECKBOX DEFAULT abap_true,   " WORKLIST
              p_c6 AS CHECKBOX DEFAULT abap_true,   " G4BA_NOHASH
              p_c7 AS CHECKBOX DEFAULT abap_true.   " LOCK_ORPHAN
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-b03.
  PARAMETERS: p_f1 AS CHECKBOX DEFAULT abap_true,   " SRVB_NO_G4BA
              p_f2 AS CHECKBOX DEFAULT abap_true,   " G4BA_NOPUBL
              p_f3 AS CHECKBOX DEFAULT abap_true,   " SU24_EMPTY
              p_wl AS CHECKBOX DEFAULT abap_false.  " TO_WORKLIST
SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-b04.
  PARAMETERS: p_target TYPE devclass,
              p_langv  TYPE c LENGTH 1 DEFAULT '5',
              p_fixall AS CHECKBOX DEFAULT abap_false,
              p_test   AS CHECKBOX DEFAULT abap_true,
              p_nodisp AS CHECKBOX DEFAULT abap_false.
SELECTION-SCREEN END OF BLOCK b4.


CLASS lcl_repair DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_issue,
             status   TYPE c LENGTH 4,
             kind     TYPE c LENGTH 12,
             category TYPE c LENGTH 14,
             object   TYPE trobjtype,
             obj_name TYPE sobj_name,
             devclass TYPE devclass,
             info     TYPE c LENGTH 255,
             action   TYPE c LENGTH 30,
             result   TYPE c LENGTH 255,
           END OF ty_issue,
           tt_issue TYPE STANDARD TABLE OF ty_issue WITH EMPTY KEY.

    CLASS-METHODS set_defaults.
    METHODS run.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_primary,
             object TYPE trobjtype,
             table  TYPE tabname,
             field  TYPE fieldname,
           END OF ty_primary,
           tt_primary TYPE STANDARD TABLE OF ty_primary WITH EMPTY KEY,
           BEGIN OF ty_tadir,
             object   TYPE trobjtype,
             obj_name TYPE sobj_name,
             devclass TYPE devclass,
           END OF ty_tadir,
           tt_tadir   TYPE SORTED TABLE OF ty_tadir WITH UNIQUE KEY object obj_name,
           tt_names   TYPE STANDARD TABLE OF sobj_name WITH EMPTY KEY.

    CONSTANTS: c_git     TYPE string VALUE `Git problem`,
               c_follow  TYPE string VALUE `Follow-up`,
               c_tool    TYPE string VALUE `Tool`,
               c_open    TYPE c LENGTH 4 VALUE '@5C@',
               c_done    TYPE c LENGTH 4 VALUE '@5B@',
               c_tested  TYPE c LENGTH 4 VALUE '@5D@',
               c_hint    TYPE c LENGTH 4 VALUE '@1E@'.

    DATA mt_issues   TYPE tt_issue.
    DATA mo_alv      TYPE REF TO cl_salv_table.
    DATA mr_packages TYPE RANGE OF devclass.

    METHODS resolve_packages.
    METHODS in_set IMPORTING i_name TYPE csequence i_devclass TYPE devclass OPTIONAL
                   RETURNING VALUE(r) TYPE abap_bool.
    METHODS select_tadir IMPORTING i_object TYPE trobjtype
                         RETURNING VALUE(rt) TYPE tt_tadir.
    METHODS primary_tables RETURNING VALUE(rt) TYPE tt_primary.
    METHODS object_exists IMPORTING i_object TYPE trobjtype i_name TYPE sobj_name
                                    i_table  TYPE tabname   i_field TYPE fieldname
                          RETURNING VALUE(r) TYPE abap_bool.
    METHODS tadir_exists IMPORTING i_object TYPE trobjtype i_name TYPE sobj_name
                         RETURNING VALUE(r) TYPE abap_bool.
    METHODS table_names IMPORTING i_table TYPE tabname i_field TYPE fieldname i_extra TYPE string OPTIONAL
                        RETURNING VALUE(rt) TYPE tt_names.
    METHODS add IMPORTING i_kind     TYPE string
                          i_category TYPE csequence
                          i_object   TYPE trobjtype
                          i_name     TYPE sobj_name
                          i_devclass TYPE devclass OPTIONAL
                          i_info     TYPE csequence
                          i_action   TYPE csequence OPTIONAL.

    " git problems
    METHODS find_orphan_tadir.
    METHODS find_drafts_without_tadir.
    METHODS find_no_package.
    METHODS find_language_dash.
    METHODS find_worklist.
    METHODS find_g4ba_without_hash.
    METHODS find_orphan_locks.
    " follow-up tasks and tool
    METHODS find_srvb_without_g4ba.
    METHODS find_g4ba_not_published.
    METHODS find_su24_empty.
    METHODS find_to_worklist.

    METHODS fix IMPORTING i_test TYPE abap_bool CHANGING cs_issue TYPE ty_issue.
    METHODS delete_tadir IMPORTING i_object TYPE trobjtype i_name TYPE sobj_name i_test TYPE abap_bool
                         RETURNING VALUE(r) TYPE string.
    METHODS delete_object_tables IMPORTING i_object TYPE trobjtype i_name TYPE sobj_name i_test TYPE abap_bool
                                 RETURNING VALUE(r) TYPE string.
    METHODS delete_worklist IMPORTING i_object TYPE trobjtype i_name TYPE sobj_name i_test TYPE abap_bool
                            RETURNING VALUE(r) TYPE string.
    METHODS insert_worklist IMPORTING i_object TYPE trobjtype i_name TYPE sobj_name i_test TYPE abap_bool
                            RETURNING VALUE(r) TYPE string.
    METHODS move_package IMPORTING i_object TYPE trobjtype i_name TYPE sobj_name i_test TYPE abap_bool
                         RETURNING VALUE(r) TYPE string.
    METHODS set_language_version IMPORTING i_object TYPE trobjtype i_name TYPE sobj_name i_test TYPE abap_bool
                                 RETURNING VALUE(r) TYPE string.
    METHODS last_message RETURNING VALUE(r) TYPE string.
    METHODS status_text IMPORTING is_issue TYPE ty_issue RETURNING VALUE(r) TYPE string.
    METHODS save.

    METHODS display.
    METHODS on_link_click FOR EVENT link_click OF cl_salv_events_table IMPORTING row column.
ENDCLASS.


CLASS lcl_repair IMPLEMENTATION.

  METHOD set_defaults.
    " Defaults for ABAP-PRC
    s_root[] = VALUE #( ( sign = 'I' option = 'EQ' low = 'ZABAP_PROCESSING_CENTER_ALL' ) ).
    s_pref[] = VALUE #( sign = 'I' option = 'CP'
                        ( low = 'ZPRC*' )     ( low = 'Z*_PRC_*' )  ( low = 'ZUIPRC*' )
                        ( low = 'ZPRCDEMO*' ) ( low = 'ZABAP_PRC*' ) ( low = 'ZBALI_PRC*' )
                        ( low = 'ZABAP_PROCESSING_CENTER*' ) ).
  ENDMETHOD.


  METHOD run.
    resolve_packages( ).

    IF p_c1 = abap_true. find_orphan_tadir( ). ENDIF.
    IF p_c2 = abap_true. find_drafts_without_tadir( ). ENDIF.
    IF p_c3 = abap_true. find_no_package( ). ENDIF.
    IF p_c4 = abap_true. find_language_dash( ). ENDIF.
    IF p_c5 = abap_true. find_worklist( ). ENDIF.
    IF p_c6 = abap_true. find_g4ba_without_hash( ). ENDIF.
    IF p_c7 = abap_true. find_orphan_locks( ). ENDIF.
    IF p_f1 = abap_true. find_srvb_without_g4ba( ). ENDIF.
    IF p_f2 = abap_true. find_g4ba_not_published( ). ENDIF.
    IF p_f3 = abap_true. find_su24_empty( ). ENDIF.
    IF p_wl = abap_true. find_to_worklist( ). ENDIF.

    SORT mt_issues BY kind category object obj_name.
    DELETE ADJACENT DUPLICATES FROM mt_issues COMPARING kind category object obj_name.

    IF p_fixall = abap_true.
      LOOP AT mt_issues ASSIGNING FIELD-SYMBOL(<issue>) WHERE action IS NOT INITIAL.
        fix( EXPORTING i_test = p_test CHANGING cs_issue = <issue> ).
      ENDLOOP.
      IF p_test = abap_false.
        COMMIT WORK.
      ENDIF.
    ENDIF.

    save( ).
    IF p_nodisp = abap_false.
      display( ).
    ENDIF.
  ENDMETHOD.


  METHOD resolve_packages.
    DATA lt_packages TYPE STANDARD TABLE OF devclass WITH EMPTY KEY.

    IF s_root[] IS INITIAL.
      RETURN.
    ENDIF.
    SELECT devclass FROM tdevc WHERE devclass IN @s_root INTO TABLE @lt_packages.
    DATA(lv_index) = 1.
    WHILE lv_index <= lines( lt_packages ).
      DATA(lv_parent) = lt_packages[ lv_index ].
      SELECT devclass FROM tdevc WHERE parentcl = @lv_parent INTO TABLE @DATA(lt_sub).
      APPEND LINES OF lt_sub TO lt_packages.
      lv_index += 1.
    ENDWHILE.
    mr_packages = VALUE #( FOR p IN lt_packages ( sign = 'I' option = 'EQ' low = p ) ).
  ENDMETHOD.


  METHOD in_set.
    IF s_pref[] IS NOT INITIAL AND i_name IN s_pref.
      r = abap_true.
    ELSEIF mr_packages IS NOT INITIAL AND i_devclass IS NOT INITIAL AND i_devclass IN mr_packages.
      r = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD select_tadir.
    " Object set = packages OR name patterns
    IF mr_packages IS NOT INITIAL.
      SELECT object, obj_name, devclass FROM tadir
        WHERE pgmid = 'R3TR' AND object = @i_object AND devclass IN @mr_packages AND delflag = @space
        INTO TABLE @DATA(lt_by_package).
      INSERT LINES OF lt_by_package INTO TABLE rt.
    ENDIF.
    IF s_pref[] IS NOT INITIAL.
      SELECT object, obj_name, devclass FROM tadir
        WHERE pgmid = 'R3TR' AND object = @i_object AND obj_name IN @s_pref AND delflag = @space
        INTO TABLE @DATA(lt_by_name).
      LOOP AT lt_by_name INTO DATA(ls_row).
        INSERT ls_row INTO TABLE rt.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD primary_tables.
    rt = VALUE #(
      ( object = 'DEVC' table = 'TDEVC'            field = 'DEVCLASS' )
      ( object = 'DDLS' table = 'DDDDLSRC'         field = 'DDLNAME' )
      ( object = 'DCLS' table = 'ACMDCLSRC'        field = 'DCLNAME' )
      ( object = 'DDLX' table = 'DDLXSRC'          field = 'DDLXNAME' )
      ( object = 'SRVD' table = 'SRVDSRC'          field = 'SRVDNAME' )
      ( object = 'SRVB' table = 'SRVB_HEAD'        field = 'SRVB_NAME' )
      ( object = 'G4BA' table = '/IWBEP/I_V4_MSGR' field = 'GROUP_ID' )
      ( object = 'SMIM' table = 'SMIMLOIO'         field = 'LOIO_ID' )
      ( object = 'WAPA' table = 'O2APPL'           field = 'APPLNAME' )
      ( object = 'SICF' table = 'ICFSERVICE'       field = 'ICF_NAME' )
      ( object = 'CLAS' table = 'SEOCLASS'         field = 'CLSNAME' )
      ( object = 'INTF' table = 'SEOCLASS'         field = 'CLSNAME' )
      ( object = 'PROG' table = 'TRDIR'            field = 'NAME' )
      ( object = 'TABL' table = 'DD02L'            field = 'TABNAME' )
      ( object = 'DTEL' table = 'DD04L'            field = 'ROLLNAME' )
      ( object = 'DOMA' table = 'DD01L'            field = 'DOMNAME' )
      ( object = 'SUSH' table = 'USOBHASH'         field = 'NAME' ) ).
  ENDMETHOD.


  METHOD object_exists.
    DATA lv_count TYPE i.
    DATA(lv_name) = CONV string( i_name ).
    DATA(lv_where) = ``.

    CASE i_object.
      WHEN 'SICF'.
        " TADIR: ICF name (15) + GUID of the parent node (25)
        lv_where = |ICF_NAME = '{ i_name(15) }' AND ICFPARGUID = '{ i_name+15(25) }'|.
      WHEN 'SUSH'.
        " TADIR: hash (30) + type (2)
        lv_where = |NAME = '{ i_name(30) }' AND TYPE = '{ i_name+30(2) }'|.
      WHEN OTHERS.
        REPLACE ALL OCCURRENCES OF `'` IN lv_name WITH `''`.
        lv_where = |{ i_field } = '{ lv_name }'|.
    ENDCASE.

    TRY.
        SELECT COUNT(*) FROM (i_table) WHERE (lv_where) INTO @lv_count.
        r = boolc( lv_count > 0 ).
      CATCH cx_sy_dynamic_osql_error.
        " table does not exist on this release: no finding
        r = abap_true.
    ENDTRY.
  ENDMETHOD.


  METHOD tadir_exists.
    SELECT SINGLE @abap_true FROM tadir
      WHERE pgmid = 'R3TR' AND object = @i_object AND obj_name = @i_name
      INTO @r.
  ENDMETHOD.


  METHOD table_names.
    " names in a source table that match the name patterns
    CHECK s_pref[] IS NOT INITIAL.
    DATA(lv_fields) = |DISTINCT { i_field }|.
    DATA(lv_where)  = |{ i_field } IN @s_pref{ i_extra }|.
    TRY.
        SELECT (lv_fields) FROM (i_table) WHERE (lv_where) INTO TABLE @rt.
      CATCH cx_sy_dynamic_osql_error.
        CLEAR rt.
    ENDTRY.
  ENDMETHOD.


  METHOD add.
    APPEND VALUE #( status   = COND #( WHEN i_action IS INITIAL THEN c_hint ELSE c_open )
                    kind     = i_kind
                    category = i_category
                    object   = i_object
                    obj_name = i_name
                    devclass = i_devclass
                    info     = i_info
                    action   = i_action ) TO mt_issues.
  ENDMETHOD.


  METHOD find_orphan_tadir.
    LOOP AT primary_tables( ) INTO DATA(ls_primary).
      LOOP AT select_tadir( ls_primary-object ) INTO DATA(ls_tadir).
        IF object_exists( i_object = ls_primary-object i_name = ls_tadir-obj_name
                          i_table  = ls_primary-table  i_field = ls_primary-field ) = abap_false.
          add( i_kind = c_git i_category = 'ORPHAN_TADIR' i_object = ls_primary-object
               i_name = ls_tadir-obj_name i_devclass = ls_tadir-devclass
               i_info = |No object in { ls_primary-table }: the TADIR entry is left over and blocks new imports with this name|
               i_action = 'Delete TADIR entry' ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD find_drafts_without_tadir.
    LOOP AT primary_tables( ) INTO DATA(ls_primary)
         WHERE object = 'DDLS' OR object = 'DCLS' OR object = 'DDLX' OR object = 'SRVD' OR object = 'SRVB'.
      LOOP AT table_names( i_table = ls_primary-table i_field = ls_primary-field ) INTO DATA(lv_name).
        IF tadir_exists( i_object = ls_primary-object i_name = lv_name ) = abap_false.
          add( i_kind = c_git i_category = 'DRAFT_NOTADIR' i_object = ls_primary-object i_name = lv_name
               i_info = |Source in { ls_primary-table } without TADIR entry: ADT can neither open nor delete it|
               i_action = 'Delete source' ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD find_no_package.
    CHECK s_pref[] IS NOT INITIAL.
    SELECT t~object, t~obj_name, t~devclass
      FROM tadir AS t
      LEFT OUTER JOIN tdevc AS d ON d~devclass = t~devclass
      WHERE t~pgmid    = 'R3TR'
        AND t~object   <> 'DEVC'
        AND t~obj_name IN @s_pref
        AND t~delflag  = @space
        AND t~devclass NOT LIKE '$%'
        AND d~devclass IS NULL
      INTO TABLE @DATA(lt_rows).
    LOOP AT lt_rows INTO DATA(ls_row).
      add( i_kind = c_git i_category = 'NO_PACKAGE' i_object = ls_row-object i_name = ls_row-obj_name
           i_devclass = ls_row-devclass
           i_info = COND string( WHEN ls_row-devclass IS INITIAL
                                 THEN `No package: no software component, transport or abapGit folder`
                                 ELSE |Package { ls_row-devclass } does not exist: the object is outside every repository| )
           i_action = COND string( WHEN p_target IS NOT INITIAL THEN |Move to { p_target }| ) ).
    ENDLOOP.
  ENDMETHOD.


  METHOD find_language_dash.
    DATA(lt_checks) = VALUE string_table( ( `DD02L;TABNAME;TABL` ) ( `DDDDLSRC;DDLNAME;DDLS` ) ).
    LOOP AT lt_checks INTO DATA(lv_check).
      SPLIT lv_check AT ';' INTO DATA(lv_table) DATA(lv_field) DATA(lv_object).
      LOOP AT table_names( i_table = CONV #( lv_table ) i_field = CONV #( lv_field )
                           i_extra = ` AND ABAP_LANGUAGE_VERSION = '-'` ) INTO DATA(lv_name).
        add( i_kind = c_git i_category = 'LANG_DASH' i_object = CONV #( lv_object ) i_name = lv_name
             i_info = |Language version '-' in { lv_table } (abapGit "Ignore"): cannot be activated or deleted|
             i_action = |Set language version '{ p_langv }'| ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD find_worklist.
    SELECT DISTINCT object, obj_name FROM dwinactiv
      WHERE object IN ( 'DDLS', 'DCLS', 'DDLX', 'SRVD', 'SRVB', 'BDEF', 'TABL', 'DTEL', 'DOMA', 'PROG', 'CLAS', 'INTF' )
      INTO TABLE @DATA(lt_rows).
    LOOP AT lt_rows INTO DATA(ls_row).
      DATA(lv_name) = CONV sobj_name( ls_row-obj_name ).
      CHECK in_set( lv_name ) = abap_true.
      IF tadir_exists( i_object = ls_row-object i_name = lv_name ) = abap_false.
        add( i_kind = c_git i_category = 'WORKLIST' i_object = ls_row-object i_name = lv_name
             i_info = `In the inactive worklist, but no TADIR entry: every mass activation stumbles over it`
             i_action = 'Remove from worklist' ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD find_g4ba_without_hash.
    LOOP AT select_tadir( 'G4BA' ) INTO DATA(ls_g4ba).
      DATA(lv_hash) = abap_false.
      SELECT SINGLE @abap_true FROM usobhash
        WHERE pgmid = 'R3TR' AND object = 'G4BA' AND obj_name = @ls_g4ba-obj_name
        INTO @lv_hash.
      IF lv_hash = abap_false
         AND object_exists( i_object = 'G4BA' i_name = ls_g4ba-obj_name
                            i_table = '/IWBEP/I_V4_MSGR' i_field = 'GROUP_ID' ) = abap_true.
        add( i_kind = c_git i_category = 'G4BA_NOHASH' i_object = 'G4BA' i_name = ls_g4ba-obj_name
             i_devclass = ls_g4ba-devclass
             i_info = `No USOBHASH (G4BA from a table copy): SU24 does not find the service. Activate the SRVB afterwards`
             i_action = 'Delete G4BA' ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD find_orphan_locks.
    SELECT trkorr, object, lokey FROM tlock
      WHERE lokey LIKE 'Z%' OR lokey LIKE 'Y%' OR lokey LIKE '/%'
      INTO TABLE @DATA(lt_locks).
    LOOP AT lt_locks INTO DATA(ls_lock).
      " base name: lock keys are padded with null bytes and may carry suffixes (sub-object, ADIR, ...)
      DATA(lv_key) = CONV string( ls_lock-lokey ).
      FIND FIRST OCCURRENCE OF REGEX `^[A-Z0-9_/]+` IN lv_key MATCH LENGTH DATA(lv_len).
      CHECK sy-subrc = 0.
      DATA(lv_base) = substring( val = lv_key len = lv_len ).
      DATA(lv_name) = CONV sobj_name( lv_base ).
      CHECK in_set( lv_name ) = abap_true.
      SELECT trkorr FROM e070
        WHERE trkorr = @ls_lock-trkorr OR strkorr = @ls_lock-trkorr
        INTO TABLE @DATA(lt_requests).
      DATA(lv_found) = abap_false.
      IF lt_requests IS NOT INITIAL.
        " any object type: the request may hold the object as R3TR or as LIMU sub-object
        DATA(lv_like) = |{ lv_base }%|.
        SELECT obj_name FROM e071
          FOR ALL ENTRIES IN @lt_requests
          WHERE trkorr = @lt_requests-trkorr AND obj_name LIKE @lv_like
          INTO TABLE @DATA(lt_e071).
        lv_found = boolc( lt_e071 IS NOT INITIAL ).
      ENDIF.
      IF lv_found = abap_false.
        add( i_kind = c_git i_category = 'LOCK_ORPHAN' i_object = ls_lock-object i_name = lv_name
             i_info = |Locked in { ls_lock-trkorr } without entry in the request: blocks moving and deleting. Release the request| ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD find_srvb_without_g4ba.
    LOOP AT select_tadir( 'SRVB' ) INTO DATA(ls_srvb).
      CHECK object_exists( i_object = 'SRVB' i_name = ls_srvb-obj_name
                           i_table = 'SRVB_HEAD' i_field = 'SRVB_NAME' ) = abap_true.
      IF object_exists( i_object = 'G4BA' i_name = ls_srvb-obj_name
                        i_table = '/IWBEP/I_V4_MSGR' i_field = 'GROUP_ID' ) = abap_false.
        add( i_kind = c_follow i_category = 'SRVB_NO_G4BA' i_object = 'SRVB' i_name = ls_srvb-obj_name
             i_devclass = ls_srvb-devclass
             i_info = `Service binding not activated: no service group, the service cannot be published and SU24 does not find it`
             i_action = 'To worklist (then activate)' ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD find_g4ba_not_published.
    DATA lv_count TYPE i.
    LOOP AT select_tadir( 'G4BA' ) INTO DATA(ls_g4ba).
      CHECK object_exists( i_object = 'G4BA' i_name = ls_g4ba-obj_name
                           i_table = '/IWBEP/I_V4_MSGR' i_field = 'GROUP_ID' ) = abap_true.
      DATA(lv_where) = |GROUP_ID = '{ ls_g4ba-obj_name }'|.
      TRY.
          SELECT COUNT(*) FROM ('/IWFND/C_V4_MSGR') WHERE (lv_where) INTO @lv_count.
        CATCH cx_sy_dynamic_osql_error.
          CONTINUE.
      ENDTRY.
      IF lv_count = 0.
        add( i_kind = c_follow i_category = 'G4BA_NOPUBL' i_object = 'G4BA' i_name = ls_g4ba-obj_name
             i_devclass = ls_g4ba-devclass
             i_info = `Service group not published: the app gets no data. /IWFND/V4_ADMIN, Publish Service Groups, alias LOCAL` ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD find_su24_empty.
    " registered applications (USOBHASH) of the object set without SU24 values
    DATA(lt_apps) = VALUE tt_tadir( ).
    INSERT LINES OF select_tadir( 'G4BA' ) INTO TABLE lt_apps.
    INSERT LINES OF select_tadir( 'SAJC' ) INTO TABLE lt_apps.
    LOOP AT lt_apps INTO DATA(ls_app).
      SELECT SINGLE name, type FROM usobhash
        WHERE pgmid = 'R3TR' AND object = @ls_app-object AND obj_name = @ls_app-obj_name
        INTO @DATA(ls_hash).
      CHECK sy-subrc = 0.
      SELECT SINGLE @abap_true FROM usobx_c
        WHERE name = @ls_hash-name AND type = @ls_hash-type
        INTO @DATA(lv_values).
      IF lv_values = abap_false.
        add( i_kind = c_follow i_category = 'SU24_EMPTY' i_object = ls_app-object i_name = ls_app-obj_name
             i_devclass = ls_app-devclass
             i_info = |No SU24 default values (hash { ls_hash-name }): roles get no proposals for this application| ).
      ENDIF.
      CLEAR lv_values.
    ENDLOOP.
  ENDMETHOD.


  METHOD find_to_worklist.
    DATA(lt_types) = VALUE string_table( ( `DDLS` ) ( `DCLS` ) ( `DDLX` ) ( `BDEF` ) ( `SRVD` ) ( `SRVB` ) ).
    LOOP AT lt_types INTO DATA(lv_type).
      LOOP AT select_tadir( CONV #( lv_type ) ) INTO DATA(ls_row).
        add( i_kind = c_tool i_category = 'TO_WORKLIST' i_object = ls_row-object i_name = ls_row-obj_name
             i_devclass = ls_row-devclass
             i_info = `For the mass activation (ADT: Activate Inactive Objects)`
             i_action = 'To worklist' ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD fix.
    IF cs_issue-action IS INITIAL OR cs_issue-status = c_done.
      RETURN.
    ENDIF.

    DATA(lv_result) = ``.
    CASE cs_issue-category.
      WHEN 'ORPHAN_TADIR'.
        lv_result = delete_worklist( i_object = cs_issue-object i_name = cs_issue-obj_name i_test = i_test )
                 && ` / ` && delete_tadir( i_object = cs_issue-object i_name = cs_issue-obj_name i_test = i_test ).
      WHEN 'DRAFT_NOTADIR'.
        lv_result = delete_object_tables( i_object = cs_issue-object i_name = cs_issue-obj_name i_test = i_test ).
      WHEN 'NO_PACKAGE'.
        lv_result = move_package( i_object = cs_issue-object i_name = cs_issue-obj_name i_test = i_test ).
      WHEN 'LANG_DASH'.
        lv_result = set_language_version( i_object = cs_issue-object i_name = cs_issue-obj_name i_test = i_test ).
      WHEN 'WORKLIST'.
        lv_result = delete_worklist( i_object = cs_issue-object i_name = cs_issue-obj_name i_test = i_test ).
      WHEN 'G4BA_NOHASH'.
        lv_result = delete_object_tables( i_object = cs_issue-object i_name = cs_issue-obj_name i_test = i_test )
                 && ` / ` && delete_tadir( i_object = cs_issue-object i_name = cs_issue-obj_name i_test = i_test ).
      WHEN 'SRVB_NO_G4BA' OR 'TO_WORKLIST'.
        lv_result = insert_worklist( i_object = cs_issue-object i_name = cs_issue-obj_name i_test = i_test ).
    ENDCASE.

    cs_issue-result = lv_result.
    IF lv_result CS 'ERROR'.
      cs_issue-status = c_open.
    ELSEIF i_test = abap_false.
      cs_issue-status = c_done.
    ELSE.
      cs_issue-status = c_tested.
    ENDIF.
  ENDMETHOD.


  METHOD delete_tadir.
    IF tadir_exists( i_object = i_object i_name = i_name ) = abap_false.
      r = `TADIR: no entry`.
      RETURN.
    ENDIF.
    CALL FUNCTION 'TR_TADIR_INTERFACE'
      EXPORTING
        wi_delete_tadir_entry = abap_true
        wi_test_modus         = i_test
        wi_tadir_pgmid        = 'R3TR'
        wi_tadir_object       = i_object
        wi_tadir_obj_name     = i_name
      EXCEPTIONS
        OTHERS                = 1.
    IF sy-subrc = 0.
      r = COND #( WHEN i_test = abap_true THEN `TADIR: can be deleted` ELSE `TADIR deleted` ).
    ELSE.
      r = |ERROR TADIR: { last_message( ) }|.
    ENDIF.
  ENDMETHOD.


  METHOD delete_object_tables.
    DATA lv_count TYPE i.
    DATA lv_total TYPE i.

    SELECT tobj_name FROM objsl
      WHERE objectname = @i_object AND objecttype = 'L' AND tobject = 'TABU'
      INTO TABLE @DATA(lt_tables).
    LOOP AT lt_tables INTO DATA(lv_tobj).
      DATA(lv_table) = CONV tabname( lv_tobj ).
      DATA(lv_field) = VALUE fieldname( ).
      TRY.
          DATA(lo_struct) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( lv_table ) ).
          LOOP AT lo_struct->get_ddic_field_list( ) INTO DATA(ls_field) WHERE keyflag = abap_true.
            CHECK ls_field-datatype <> 'CLNT'.
            lv_field = ls_field-fieldname.
            EXIT.
          ENDLOOP.
        CATCH cx_root.
          CONTINUE.
      ENDTRY.
      CHECK lv_field IS NOT INITIAL.
      DATA(lv_where) = |{ lv_field } = '{ i_name }'|.
      TRY.
          IF i_test = abap_true.
            SELECT COUNT(*) FROM (lv_table) WHERE (lv_where) INTO @lv_count.
          ELSE.
            DELETE FROM (lv_table) WHERE (lv_where).
            lv_count = sy-dbcnt.
          ENDIF.
          lv_total += lv_count.
        CATCH cx_sy_dynamic_osql_error.
      ENDTRY.
    ENDLOOP.

    r = |{ lv_total } row(s) { COND string( WHEN i_test = abap_true THEN `to delete` ELSE `deleted` ) }|
     && ` / ` && delete_worklist( i_object = i_object i_name = i_name i_test = i_test ).
  ENDMETHOD.


  METHOD delete_worklist.
    SELECT COUNT(*) FROM dwinactiv
      WHERE object = @i_object AND obj_name = @i_name
      INTO @DATA(lv_count).
    IF lv_count = 0.
      r = `Worklist: no entry`.
      RETURN.
    ENDIF.
    IF i_test = abap_true.
      r = |Worklist: { lv_count } entry/entries|.
      RETURN.
    ENDIF.
    CALL FUNCTION 'RS_DELETE_FROM_WORKING_AREA'
      EXPORTING
        object                 = i_object
        obj_name               = CONV trobj_name( i_name )
        immediate              = abap_true
        actualize_working_area = abap_true
      EXCEPTIONS
        OTHERS                 = 1.
    r = COND #( WHEN sy-subrc = 0 THEN `Worklist cleaned up` ELSE |ERROR worklist: { sy-subrc }| ).
  ENDMETHOD.


  METHOD insert_worklist.
    IF i_test = abap_true.
      r = `Will be added to the worklist`.
      RETURN.
    ENDIF.
    CALL FUNCTION 'RS_INSERT_INTO_WORKING_AREA'
      EXPORTING
        object            = i_object
        obj_name          = CONV trobj_name( i_name )
      EXCEPTIONS
        wrong_object_name = 1
        OTHERS            = 2.
    r = COND #( WHEN sy-subrc = 0 THEN `Added to the worklist - activate now` ELSE |ERROR: { last_message( ) }| ).
  ENDMETHOD.


  METHOD move_package.
    IF p_target IS INITIAL.
      r = `ERROR: target package P_TARGET missing`.
      RETURN.
    ENDIF.
    CALL FUNCTION 'TR_TADIR_INTERFACE'
      EXPORTING
        wi_test_modus     = i_test
        wi_tadir_pgmid    = 'R3TR'
        wi_tadir_object   = i_object
        wi_tadir_obj_name = i_name
        wi_tadir_devclass = p_target
      EXCEPTIONS
        OTHERS            = 1.
    IF sy-subrc = 0.
      r = |{ COND string( WHEN i_test = abap_true THEN `Possible:` ELSE `Moved:` ) } { p_target }|.
    ELSE.
      r = |ERROR: { last_message( ) }|.
    ENDIF.
  ENDMETHOD.


  METHOD set_language_version.
    DATA lv_count TYPE i.
    DATA(lv_table) = SWITCH tabname( i_object WHEN 'TABL' THEN 'DD02L' WHEN 'DDLS' THEN 'DDDDLSRC' ).
    DATA(lv_field) = SWITCH fieldname( i_object WHEN 'TABL' THEN 'TABNAME' WHEN 'DDLS' THEN 'DDLNAME' ).
    DATA(lv_where) = |{ lv_field } = '{ i_name }' AND ABAP_LANGUAGE_VERSION = '-'|.
    DATA(lv_set)   = |ABAP_LANGUAGE_VERSION = '{ p_langv }'|.
    TRY.
        IF i_test = abap_true.
          SELECT COUNT(*) FROM (lv_table) WHERE (lv_where) INTO @lv_count.
          r = |{ lv_count } row(s) in { lv_table } to change|.
        ELSE.
          UPDATE (lv_table) SET (lv_set) WHERE (lv_where).
          r = |{ sy-dbcnt } row(s) in { lv_table } changed - activate or delete the object now|.
        ENDIF.
      CATCH cx_sy_dynamic_osql_error INTO DATA(lx).
        r = |ERROR: { lx->get_text( ) }|.
    ENDTRY.
  ENDMETHOD.


  METHOD status_text.
    r = SWITCH #( is_issue-status
                  WHEN c_done   THEN `DONE`
                  WHEN c_tested THEN `TESTED`
                  WHEN c_hint   THEN `HINT`
                  ELSE COND #( WHEN is_issue-result CS 'ERROR' THEN `ERROR` ELSE `OPEN` ) ).
  ENDMETHOD.


  METHOD save.
    DATA lt_db  TYPE STANDARD TABLE OF zprc_git_finding WITH EMPTY KEY.
    DATA lv_ts  TYPE timestampl.
    DATA lv_seq TYPE i.

    GET TIME STAMP FIELD lv_ts.
    LOOP AT mt_issues INTO DATA(ls_issue).
      lv_seq += 1.
      APPEND VALUE #( seqno     = lv_seq
                      run_ts    = lv_ts
                      test_mode = p_test
                      status    = status_text( ls_issue )
                      kind      = ls_issue-kind
                      category  = ls_issue-category
                      object    = ls_issue-object
                      obj_name  = ls_issue-obj_name
                      devclass  = ls_issue-devclass
                      finding   = ls_issue-info
                      action    = ls_issue-action
                      outcome   = ls_issue-result ) TO lt_db.
    ENDLOOP.

    DELETE FROM zprc_git_finding.
    INSERT zprc_git_finding FROM TABLE @lt_db.
    COMMIT WORK.
  ENDMETHOD.


  METHOD last_message.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO r.
  ENDMETHOD.


  METHOD display.
    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = mo_alv
                                CHANGING  t_table      = mt_issues ).
      CATCH cx_salv_msg.
        RETURN.
    ENDTRY.

    mo_alv->get_functions( )->set_all( abap_true ).
    mo_alv->get_display_settings( )->set_list_header(
      |Git repair: { lines( mt_issues ) } finding(s){ COND string( WHEN p_test = abap_false AND p_fixall = abap_true THEN ` - repaired` ) }| ).
    mo_alv->get_display_settings( )->set_striped_pattern( abap_true ).

    DATA(lo_columns) = mo_alv->get_columns( ).
    lo_columns->set_optimize( abap_true ).
    TRY.
        DATA(lo_status) = CAST cl_salv_column_table( lo_columns->get_column( 'STATUS' ) ).
        lo_status->set_icon( abap_true ).
        lo_status->set_long_text( 'Status' ).
        CAST cl_salv_column_table( lo_columns->get_column( 'KIND' ) )->set_long_text( 'Kind' ).
        CAST cl_salv_column_table( lo_columns->get_column( 'CATEGORY' ) )->set_long_text( 'Category' ).
        CAST cl_salv_column_table( lo_columns->get_column( 'INFO' ) )->set_long_text( 'Finding' ).
        CAST cl_salv_column_table( lo_columns->get_column( 'RESULT' ) )->set_long_text( 'Result' ).
        DATA(lo_action) = CAST cl_salv_column_table( lo_columns->get_column( 'ACTION' ) ).
        lo_action->set_long_text( 'Action (click)' ).
        lo_action->set_cell_type( if_salv_c_cell_type=>hotspot ).
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        mo_alv->get_sorts( )->add_sort( columnname = 'KIND' ).
        mo_alv->get_sorts( )->add_sort( columnname = 'CATEGORY' ).
      CATCH cx_salv_not_found cx_salv_existing cx_salv_data_error.
    ENDTRY.

    SET HANDLER on_link_click FOR mo_alv->get_event( ).
    mo_alv->display( ).
  ENDMETHOD.


  METHOD on_link_click.
    DATA lv_answer TYPE c LENGTH 1.

    ASSIGN mt_issues[ row ] TO FIELD-SYMBOL(<issue>).
    IF sy-subrc <> 0 OR column <> 'ACTION' OR <issue>-action IS INITIAL OR <issue>-status = c_done.
      RETURN.
    ENDIF.

    " test run first, then confirm
    DATA(ls_test) = <issue>.
    fix( EXPORTING i_test = abap_true CHANGING cs_issue = ls_test ).

    DATA(lv_question) = |{ <issue>-action }: { <issue>-object } { <issue>-obj_name }? Test run: { ls_test-result }|.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Git repair'
        text_question         = lv_question
        text_button_1         = 'Execute'
        text_button_2         = 'Cancel'
        display_cancel_button = abap_false
      IMPORTING
        answer                = lv_answer
      EXCEPTIONS
        OTHERS                = 1.
    IF sy-subrc <> 0 OR lv_answer <> '1'.
      RETURN.
    ENDIF.

    fix( EXPORTING i_test = abap_false CHANGING cs_issue = <issue> ).
    COMMIT WORK.
    save( ).
    mo_alv->refresh( ).
  ENDMETHOD.

ENDCLASS.


INITIALIZATION.
  lcl_repair=>set_defaults( ).

START-OF-SELECTION.
  NEW lcl_repair( )->run( ).
