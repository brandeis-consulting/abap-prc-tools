*&---------------------------------------------------------------------*
*& Report ZPRC_SET_PKG_LANGU_VERSION
*&---------------------------------------------------------------------*
*& Copies software component, transport attributes and ABAP language
*& version of a template package directly into TDEVC of a target package.
*& Existing objects in the package keep their own language version.
*&---------------------------------------------------------------------*
REPORT zprc_set_pkg_langu_version.

TYPES: BEGIN OF ty_attr,
         dlvunit      TYPE tdevc-dlvunit,
         tpclass      TYPE tdevc-tpclass,
         korrflag     TYPE tdevc-korrflag,
         pdevclass    TYPE tdevc-pdevclass,
         package_kind TYPE tdevc-package_kind,
       END OF ty_attr.

PARAMETERS p_pack  TYPE devclass DEFAULT 'ZABAP_PRC_TEST_ERROR_BAPI' OBLIGATORY.
PARAMETERS p_templ TYPE devclass DEFAULT 'ZABAP_PRC_FIORI_CONTENT' OBLIGATORY.
PARAMETERS p_test  AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.
  DATA ls_old TYPE ty_attr.
  DATA ls_new TYPE ty_attr.

  SELECT SINGLE dlvunit, tpclass, korrflag, pdevclass, package_kind
    FROM tdevc WHERE devclass = @p_pack
    INTO CORRESPONDING FIELDS OF @ls_old.
  IF sy-subrc <> 0.
    WRITE / |Target package { p_pack } not found.|.
    RETURN.
  ENDIF.

  SELECT SINGLE dlvunit, tpclass, korrflag, pdevclass, package_kind
    FROM tdevc WHERE devclass = @p_templ
    INTO CORRESPONDING FIELDS OF @ls_new.
  IF sy-subrc <> 0.
    WRITE / |Template package { p_templ } not found.|.
    RETURN.
  ENDIF.

  WRITE: / |Target package { p_pack }, template { p_templ }|,
         /,
         / 'Field',                 25 'old',               40 'new',
         / 'DLVUNIT',               25 ls_old-dlvunit,      40 ls_new-dlvunit,
         / 'TPCLASS',               25 ls_old-tpclass,      40 ls_new-tpclass,
         / 'KORRFLAG',              25 ls_old-korrflag,     40 ls_new-korrflag,
         / 'PDEVCLASS',             25 ls_old-pdevclass,    40 ls_new-pdevclass,
         / 'PACKAGE_KIND',          25 ls_old-package_kind, 40 ls_new-package_kind,
         /.

  IF ls_old = ls_new.
    WRITE / 'No change necessary.'.
    RETURN.
  ENDIF.

  IF p_test = abap_true.
    WRITE / 'Test run - nothing changed.'.
    RETURN.
  ENDIF.

  UPDATE tdevc SET dlvunit      = @ls_new-dlvunit,
                   tpclass      = @ls_new-tpclass,
                   korrflag     = @ls_new-korrflag,
                   pdevclass    = @ls_new-pdevclass,
                   package_kind = @ls_new-package_kind
    WHERE devclass = @p_pack.
  IF sy-subrc = 0.
    COMMIT WORK.
    WRITE / 'TDEVC updated.'.
  ELSE.
    ROLLBACK WORK.
    WRITE / |Update failed (sy-subrc = { sy-subrc }).|.
  ENDIF.
