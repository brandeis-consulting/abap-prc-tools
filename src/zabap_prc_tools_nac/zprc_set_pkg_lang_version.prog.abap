*&---------------------------------------------------------------------*
*& Report ZPRC_SET_PKG_LANG_VERSION
*&---------------------------------------------------------------------*
*& Sets the ABAP language version of packages directly in TDEVC
*& (field PACKAGE_KIND, domain ABAP_LANGUAGE_VERSION):
*&   ' ' = Standard ABAP, '2' = ABAP for Key Users,
*&   '5' = ABAP for Cloud Development
*&
*& Only the package attribute is changed. The language version of the
*& objects inside the packages is NOT touched.
*& Direct database update - intended for sandbox systems only.
*&---------------------------------------------------------------------*
REPORT zprc_set_pkg_lang_version.

TABLES tdevc.

SELECT-OPTIONS s_pack FOR tdevc-devclass OBLIGATORY.
PARAMETERS: p_vers TYPE abap_language_version DEFAULT space,
            p_sub  AS CHECKBOX DEFAULT space,
            p_test AS CHECKBOX DEFAULT 'X'.

INITIALIZATION.
  s_pack[] = VALUE #( sign = 'I' option = 'EQ'
                      ( low = 'ZABAP_PROCESSING_CENTER' )
                      ( low = 'ZABAP_PRC_FIORI_CONTENT' ) ).

START-OF-SELECTION.
  TYPES: BEGIN OF ty_pack,
           devclass     TYPE devclass,
           parentcl     TYPE parentcl,
           package_kind TYPE abap_language_version,
         END OF ty_pack.
  DATA lt_pack TYPE STANDARD TABLE OF ty_pack WITH EMPTY KEY.

  SELECT devclass, parentcl, package_kind FROM tdevc
    WHERE devclass IN @s_pack
    ORDER BY devclass
    INTO TABLE @lt_pack.

  " optionally include all subpackages
  IF p_sub = abap_true.
    DATA(lv_index) = 1.
    WHILE lv_index <= lines( lt_pack ).
      DATA(lv_parent) = lt_pack[ lv_index ]-devclass.
      SELECT devclass, parentcl, package_kind FROM tdevc
        WHERE parentcl = @lv_parent
        INTO TABLE @DATA(lt_sub).
      LOOP AT lt_sub INTO DATA(ls_sub).
        IF NOT line_exists( lt_pack[ devclass = ls_sub-devclass ] ).
          APPEND ls_sub TO lt_pack.
        ENDIF.
      ENDLOOP.
      lv_index += 1.
    ENDWHILE.
  ENDIF.

  IF lt_pack IS INITIAL.
    MESSAGE 'No packages found' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  DATA(lv_changed) = 0.

  WRITE: / COND string( WHEN p_test = abap_true THEN `TEST MODE - no changes` ELSE `UPDATE MODE` ) COLOR COL_HEADING.
  ULINE.
  WRITE: / 'Package', 33 'Parent', 65 'Old', 72 'New', 79 'Result'.
  ULINE.

  LOOP AT lt_pack INTO DATA(ls_pack).
    DATA(lv_result) = ``.
    IF ls_pack-package_kind = p_vers.
      lv_result = `unchanged`.
    ELSEIF p_test = abap_true.
      lv_result = `would be changed`.
    ELSE.
      UPDATE tdevc SET package_kind = @p_vers,
                       changed_by   = @sy-uname,
                       changed_on   = @sy-datum
        WHERE devclass = @ls_pack-devclass.
      lv_result = COND #( WHEN sy-subrc = 0 THEN `changed` ELSE |error sy-subrc { sy-subrc }| ).
      IF sy-subrc = 0.
        lv_changed += 1.
      ENDIF.
    ENDIF.

    WRITE: / ls_pack-devclass,
          33 ls_pack-parentcl,
          65 |'{ ls_pack-package_kind }'|,
          72 |'{ p_vers }'|,
          79 lv_result.
  ENDLOOP.

  IF p_test = abap_false.
    COMMIT WORK.
    ULINE.
    WRITE: / |{ lv_changed } package(s) changed.|.
  ENDIF.
