*&---------------------------------------------------------------------*
*& Report ZPRC_TRANSLATE_DE
*&---------------------------------------------------------------------*
*& Translates the short texts of the ABAP Processing Center (EN -> DE)
*& via the LXE API (the same API SE63 uses). Internal tool of the
*& private repository ABAP-PRC-TOOLS (package ZABAP_PRC_TOOLS_NAC).
*&
*& Defaults: run it directly - all object types of core, test, demo and
*& tools repository, missing German texts are filled, existing ones kept.
*&
*& - Reads all objects of the package trees below S_ROOT (TADIR);
*&   default: ZABAP_PROCESSING_CENTER_ALL. S_TYPE restricts the object
*&   types; empty = all
*& - Expands each object into its LXE translation objects
*&   (object types without own LXE texts, e.g. BDEF/STOB, are skipped)
*& - Fills missing target texts from the dictionary in the includes
*&   ZPRC_TRANSLATE_DE_DICT, _DICT2, _DICT3, _DICT4 and _DICT5:
*&     1. exact English text (with optional short variant), also with
*&        surplus blanks removed (some LXE texts carry invisible blanks)
*&     2. prefix rules ("DCL for ..." -> "DCL für ...")
*&     3. technical names (no blank, upper case) are copied unchanged
*& - P_OVWR replaces existing German texts that have a dictionary entry;
*&   texts without an entry are left as they are
*& - Upper case is only applied if the English source is upper case,
*&   too (the LXE flag is set for mixed-case DDLX/SRVD texts as well)
*& - In update mode the texts are read with READ_ONLY = space: the
*&   object specific LXE readers (CLAS, TLGS, VALU, ...) only then build
*&   the key mapping their writers need
*& - P_TEST only shows what would happen
*& - Each run replaces the content of table ZPRC_TRL_RESULT
*&
*& Status: TRANSLATED / SIMULATED, EXISTS, NO_ENTRY, TOO_LONG, SKIPPED,
*&         ERROR
*&---------------------------------------------------------------------*
REPORT zprc_translate_de.

TABLES: tadir, tdevc.

SELECT-OPTIONS s_root FOR tdevc-devclass NO INTERVALS OBLIGATORY.
SELECT-OPTIONS s_type FOR tadir-object.
PARAMETERS: p_slang TYPE lxeisolang DEFAULT 'enUS' OBLIGATORY,
            p_tlang TYPE lxeisolang DEFAULT 'deDE' OBLIGATORY,
            p_ovwr  AS CHECKBOX DEFAULT space,
            p_test  AS CHECKBOX DEFAULT space.

CLASS lcl_translator DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
             status   TYPE c LENGTH 12,
             object   TYPE trobjtype,
             obj_name TYPE sobj_name,
             lxe_type TYPE lxeobjtype,
             lxe_name TYPE lxeobjname,
             textkey  TYPE lxetextkey,
             max_len  TYPE i,
             source   TYPE string,
             target   TYPE string,
             info     TYPE string,
           END OF ty_result,
           tt_result TYPE STANDARD TABLE OF ty_result WITH EMPTY KEY.

    METHODS constructor IMPORTING i_slang     TYPE lxeisolang
                                  i_tlang     TYPE lxeisolang
                                  i_overwrite TYPE abap_bool
                                  i_test      TYPE abap_bool.
    METHODS run IMPORTING i_root TYPE devclass.
    METHODS save.
    METHODS display.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_dict,
             en       TYPE string,
             de       TYPE string,
             de_short TYPE string,
           END OF ty_dict,
           BEGIN OF ty_prefix,
             en TYPE string,
             de TYPE string,
           END OF ty_prefix.

    DATA mt_dict      TYPE HASHED TABLE OF ty_dict WITH UNIQUE KEY en.
    DATA mt_prefix    TYPE STANDARD TABLE OF ty_prefix WITH EMPTY KEY.
    DATA mt_result    TYPE tt_result.
    DATA mv_slang     TYPE lxeisolang.
    DATA mv_tlang     TYPE lxeisolang.
    DATA mv_overwrite TYPE abap_bool.
    DATA mv_test      TYPE abap_bool.

    METHODS add IMPORTING en TYPE string de TYPE string de_short TYPE string OPTIONAL.
    METHODS add_prefix IMPORTING en TYPE string de TYPE string.
    METHODS set_short IMPORTING en TYPE string de_short TYPE string.
    METHODS fill_dictionary.
    METHODS lookup IMPORTING i_source  TYPE string
                             i_max_len TYPE i
                   EXPORTING e_target  TYPE string
                             e_found   TYPE abap_bool.
    METHODS translate_object IMPORTING i_object   TYPE trobjtype
                                       i_obj_name TYPE sobj_name.
    METHODS translate_lxe_object IMPORTING i_object   TYPE trobjtype
                                           i_obj_name TYPE sobj_name
                                           is_colob   TYPE lxe_colob.
ENDCLASS.

CLASS lcl_translator IMPLEMENTATION.

  METHOD constructor.
    mv_slang     = i_slang.
    mv_tlang     = i_tlang.
    mv_overwrite = i_overwrite.
    mv_test      = i_test.
    fill_dictionary( ).
  ENDMETHOD.

  METHOD run.
    DATA lt_packages TYPE STANDARD TABLE OF devclass WITH EMPTY KEY.
    DATA lr_packages TYPE RANGE OF devclass.

    APPEND i_root TO lt_packages.
    DATA(lv_index) = 1.
    WHILE lv_index <= lines( lt_packages ).
      DATA(lv_parent) = lt_packages[ lv_index ].
      SELECT devclass FROM tdevc
        WHERE parentcl = @lv_parent
        INTO TABLE @DATA(lt_sub).
      APPEND LINES OF lt_sub TO lt_packages.
      lv_index += 1.
    ENDWHILE.

    lr_packages = VALUE #( FOR p IN lt_packages ( sign = 'I' option = 'EQ' low = p ) ).

    SELECT object, obj_name FROM tadir
      WHERE pgmid    = 'R3TR'
        AND devclass IN @lr_packages
        AND object   IN @s_type
        AND delflag  = @space
      ORDER BY object, obj_name
      INTO TABLE @DATA(lt_tadir).

    LOOP AT lt_tadir INTO DATA(ls_tadir).
      translate_object( i_object   = ls_tadir-object
                        i_obj_name = ls_tadir-obj_name ).
    ENDLOOP.
  ENDMETHOD.

  METHOD translate_object.
    DATA lt_colob TYPE STANDARD TABLE OF lxe_colob.

    CALL FUNCTION 'LXE_OBJ_EXPAND_TRANSPORT_OBJ'
      EXPORTING
        pgmid           = 'R3TR'
        object          = i_object
        obj_name        = CONV trobj_name( i_obj_name )
      TABLES
        ex_colob        = lt_colob
      EXCEPTIONS
        unknown_object  = 1
        unknown_ta_type = 2
        OTHERS          = 3.
    IF sy-subrc = 2.
      " object type without own LXE texts (e.g. BDEF, STOB)
      RETURN.
    ELSEIF sy-subrc <> 0.
      APPEND VALUE #( status = 'ERROR' object = i_object obj_name = i_obj_name
                      info = |LXE_OBJ_EXPAND_TRANSPORT_OBJ sy-subrc { sy-subrc }| ) TO mt_result.
      RETURN.
    ENDIF.

    LOOP AT lt_colob INTO DATA(ls_colob).
      translate_lxe_object( i_object = i_object i_obj_name = i_obj_name is_colob = ls_colob ).
    ENDLOOP.
  ENDMETHOD.

  METHOD translate_lxe_object.
    DATA lt_pairs   TYPE STANDARD TABLE OF lxe_pcx_s1.
    DATA lt_write   TYPE STANDARD TABLE OF lxe_pcx_s1.
    DATA lv_pstatus TYPE lxestatprc.
    DATA lv_err     TYPE lxestring.
    DATA lv_target  TYPE string.
    DATA lv_found   TYPE abap_bool.

    " READ_ONLY = space makes the object specific readers build the key
    " mapping that LXE_OBJ_TEXT_PAIR_WRITE needs directly afterwards
    CALL FUNCTION 'LXE_OBJ_TEXT_PAIR_READ'
      EXPORTING
        t_lang    = mv_tlang
        s_lang    = mv_slang
        custmnr   = is_colob-custmnr
        objtype   = is_colob-objtype
        objname   = is_colob-objname
        read_only = COND char1( WHEN mv_test = abap_true THEN 'X' ELSE space )
      IMPORTING
        pstatus   = lv_pstatus
        err_msg   = lv_err
      TABLES
        lt_pcx_s1 = lt_pairs.
    IF lv_pstatus = 'F'.
      APPEND VALUE #( status   = COND #( WHEN lt_pairs IS INITIAL THEN 'SKIPPED' ELSE 'ERROR' )
                      object   = i_object obj_name = i_obj_name
                      lxe_type = is_colob-objtype lxe_name = is_colob-objname
                      info     = |Read: { lv_err }| ) TO mt_result.
      RETURN.
    ENDIF.

    DATA(lv_first) = lines( mt_result ) + 1.

    LOOP AT lt_pairs ASSIGNING FIELD-SYMBOL(<ls_pair>).
      DATA(lv_source) = CONV string( <ls_pair>-s_text ).
      IF lv_source IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(ls_result) = VALUE ty_result( object   = i_object
                                         obj_name = i_obj_name
                                         lxe_type = is_colob-objtype
                                         lxe_name = is_colob-objname
                                         textkey  = <ls_pair>-textkey
                                         max_len  = <ls_pair>-unitmlt
                                         source   = lv_source
                                         target   = CONV string( <ls_pair>-t_text ) ).

      IF <ls_pair>-t_text IS NOT INITIAL AND mv_overwrite = abap_false.
        ls_result-status = 'EXISTS'.
        APPEND ls_result TO mt_result.
        CONTINUE.
      ENDIF.

      lookup( EXPORTING i_source  = lv_source
                        i_max_len = <ls_pair>-unitmlt
              IMPORTING e_target  = lv_target
                        e_found   = lv_found ).
      IF lv_found = abap_false.
        ls_result-status = 'NO_ENTRY'.
        APPEND ls_result TO mt_result.
        CONTINUE.
      ENDIF.

      " upper case only if the English source is upper case as well
      IF <ls_pair>-uppcase = abap_true AND lv_source = to_upper( lv_source ).
        TRANSLATE lv_target TO UPPER CASE.
      ENDIF.
      ls_result-target = lv_target.

      IF <ls_pair>-unitmlt > 0 AND strlen( lv_target ) > <ls_pair>-unitmlt.
        ls_result-status = 'TOO_LONG'.
        ls_result-info   = |{ strlen( lv_target ) } > { <ls_pair>-unitmlt }|.
        APPEND ls_result TO mt_result.
        CONTINUE.
      ENDIF.

      ls_result-status = COND #( WHEN mv_test = abap_true THEN 'SIMULATED' ELSE 'TRANSLATED' ).
      APPEND ls_result TO mt_result.

      <ls_pair>-t_text = lv_target.
      APPEND <ls_pair> TO lt_write.
    ENDLOOP.

    IF mv_test = abap_true OR lt_write IS INITIAL.
      RETURN.
    ENDIF.

    CLEAR: lv_pstatus, lv_err.
    CALL FUNCTION 'LXE_OBJ_TEXT_PAIR_WRITE'
      EXPORTING
        t_lang    = mv_tlang
        s_lang    = mv_slang
        custmnr   = is_colob-custmnr
        objtype   = is_colob-objtype
        objname   = is_colob-objname
      IMPORTING
        pstatus   = lv_pstatus
        err_msg   = lv_err
      TABLES
        lt_pcx_s1 = lt_write.
    IF lv_pstatus = 'F'.
      LOOP AT mt_result ASSIGNING FIELD-SYMBOL(<ls_res>) FROM lv_first WHERE status = 'TRANSLATED'.
        <ls_res>-status = 'ERROR'.
        <ls_res>-info   = |Write: { lv_err }|.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD lookup.
    CLEAR: e_target, e_found.

    " 1. exact text, short variant if the full text is too long; second try with
    "    surplus blanks removed - some LXE texts carry trailing or double blanks
    READ TABLE mt_dict INTO DATA(ls_dict) WITH TABLE KEY en = i_source.
    IF sy-subrc <> 0.
      READ TABLE mt_dict INTO ls_dict WITH TABLE KEY en = condense( i_source ).
    ENDIF.
    IF sy-subrc = 0.
      e_found  = abap_true.
      e_target = ls_dict-de.
      IF i_max_len > 0 AND strlen( e_target ) > i_max_len AND ls_dict-de_short IS NOT INITIAL.
        e_target = ls_dict-de_short.
      ENDIF.
      RETURN.
    ENDIF.

    " 2. prefix rules
    LOOP AT mt_prefix INTO DATA(ls_prefix).
      DATA(lv_len) = strlen( ls_prefix-en ).
      IF strlen( i_source ) > lv_len AND substring( val = i_source len = lv_len ) = ls_prefix-en.
        e_found  = abap_true.
        e_target = ls_prefix-de && substring( val = i_source off = lv_len ).
        RETURN.
      ENDIF.
    ENDLOOP.

    " 3. technical names are language independent
    IF find( val = i_source sub = ` ` ) = -1 AND i_source = to_upper( i_source ).
      e_found  = abap_true.
      e_target = i_source.
    ENDIF.
  ENDMETHOD.

  METHOD save.
    DATA lt_db  TYPE STANDARD TABLE OF zprc_trl_result WITH EMPTY KEY.
    DATA lv_ts  TYPE timestampl.
    DATA lv_seq TYPE i.

    GET TIME STAMP FIELD lv_ts.
    LOOP AT mt_result INTO DATA(ls_res).
      lv_seq += 1.
      APPEND VALUE #( seqno     = lv_seq
                      run_ts    = lv_ts
                      test_mode = mv_test
                      status    = ls_res-status
                      object    = ls_res-object
                      obj_name  = ls_res-obj_name
                      lxe_type  = ls_res-lxe_type
                      lxe_name  = ls_res-lxe_name
                      textkey   = ls_res-textkey
                      max_len   = ls_res-max_len
                      source    = ls_res-source
                      target    = ls_res-target
                      info      = ls_res-info ) TO lt_db.
    ENDLOOP.

    DELETE FROM zprc_trl_result.
    INSERT zprc_trl_result FROM TABLE @lt_db.
    COMMIT WORK.
    MESSAGE |{ lv_seq } results saved in ZPRC_TRL_RESULT| TYPE 'S'.
  ENDMETHOD.

  METHOD display.
    SORT mt_result BY status object obj_name textkey.
    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_alv)
                                CHANGING  t_table      = mt_result ).
        lo_alv->get_functions( )->set_all( abap_true ).
        DATA(lo_columns) = lo_alv->get_columns( ).
        lo_columns->set_optimize( abap_true ).
        DATA(lt_texts) = VALUE string_table( ( `STATUS` ) ( `Status` )
                                             ( `MAX_LEN` ) ( `Max. length` )
                                             ( `SOURCE` ) ( `Source text` )
                                             ( `TARGET` ) ( `Target text` )
                                             ( `INFO` ) ( `Info` ) ).
        DATA(lv_i) = 1.
        WHILE lv_i < lines( lt_texts ).
          DATA(lo_column) = lo_columns->get_column( CONV lvc_fname( lt_texts[ lv_i ] ) ).
          lo_column->set_long_text( CONV scrtext_l( lt_texts[ lv_i + 1 ] ) ).
          lo_column->set_medium_text( CONV scrtext_m( lt_texts[ lv_i + 1 ] ) ).
          lo_column->set_short_text( CONV scrtext_s( lt_texts[ lv_i + 1 ] ) ).
          lv_i += 2.
        ENDWHILE.
        lo_alv->get_display_settings( )->set_list_header(
            CONV lvc_title( |ABAP-PRC translation { mv_slang } -> { mv_tlang }| &&
                            COND #( WHEN mv_test = abap_true THEN ` (test mode)` ) ) ).
        lo_alv->display( ).
      CATCH cx_salv_msg cx_salv_not_found INTO DATA(lx_salv).
        MESSAGE lx_salv TYPE 'I'.
    ENDTRY.
  ENDMETHOD.

  METHOD add.
    INSERT VALUE #( en = en de = de de_short = de_short ) INTO TABLE mt_dict.
  ENDMETHOD.

  METHOD add_prefix.
    APPEND VALUE #( en = en de = de ) TO mt_prefix.
  ENDMETHOD.

  METHOD set_short.
    ASSIGN mt_dict[ en = en ] TO FIELD-SYMBOL(<ls_dict>).
    IF sy-subrc = 0.
      <ls_dict>-de_short = de_short.
    ENDIF.
  ENDMETHOD.

  METHOD fill_dictionary.
    INCLUDE zprc_translate_de_dict.
    INCLUDE zprc_translate_de_dict2.
    INCLUDE zprc_translate_de_dict3.
    INCLUDE zprc_translate_de_dict4.
    INCLUDE zprc_translate_de_dict5.
  ENDMETHOD.

ENDCLASS.

INITIALIZATION.
  " Core, test, demo and tools repository in one run, all object types
  s_root[] = VALUE #( ( sign = 'I' option = 'EQ' low = 'ZABAP_PROCESSING_CENTER_ALL' ) ).

START-OF-SELECTION.
  DATA(go_translator) = NEW lcl_translator( i_slang     = p_slang
                                            i_tlang     = p_tlang
                                            i_overwrite = p_ovwr
                                            i_test      = p_test ).
  LOOP AT s_root INTO DATA(gs_root) WHERE sign = 'I' AND option = 'EQ'.
    go_translator->run( gs_root-low ).
  ENDLOOP.
  go_translator->save( ).
  go_translator->display( ).
