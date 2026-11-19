"! <p class="shorttext synchronized">ABAP-PRC Tools: Delete all test and demo data</p>
"!
"! Classrun (F9), no parameters: deletes all processed objects of the test and demo
"! processes in every state - steps and messages included -, the runs of the test and
"! demo applications with their parameters, and the run notifications of these runs or
"! of runs that no longer exist. Other processes are never touched.
"!
"! Takes the lock of the PRC test runs: it does not run while tests are running.
CLASS zcl_prc_delete_test_demo_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES tt_uuids TYPE STANDARD TABLE OF sysuuid_x16 WITH EMPTY KEY.
    TYPES: BEGIN OF ty_object,
             uuid         TYPE sysuuid_x16,
             process_name TYPE zprc_process_name,
           END OF ty_object,
           tt_objects TYPE STANDARD TABLE OF ty_object WITH EMPTY KEY.

    "! Lock of the PRC test runs (ZCL_PRC_TEST_PROC_FIXTURE)
    CONSTANTS co_test_run_lock TYPE sysuuid_x16 VALUE 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'.
    "! Notification of a completed run: the object refers to the run by its UUID
    CONSTANTS co_run_notification TYPE zprc_process_name VALUE 'PRC_RUN_COMPLETED'.
    "! Rows per DELETE statement
    CONSTANTS co_package_size TYPE i VALUE 1000.

    METHODS lock RETURNING VALUE(r_locked) TYPE abap_bool.
    METHODS delete_objects IMPORTING i_objects TYPE tt_objects.
    METHODS delete_runs IMPORTING i_runs TYPE tt_uuids.
ENDCLASS.



CLASS zcl_prc_delete_test_demo_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    " Test and demo processes, including names before the renaming to TEST_* / DEMO_*
    DATA processes TYPE RANGE OF zprc_process_name.
    DATA applications TYPE RANGE OF zprc_run_app_name.
    DATA runs TYPE tt_uuids.
    DATA objects TYPE tt_objects.

    processes = VALUE #( sign = 'I' ( option = 'CP' low = 'TEST_*' )
                                    ( option = 'CP' low = 'DEMO_*' )
                                    ( option = 'CP' low = 'PRC_TEST_*' )
                                    ( option = 'EQ' low = 'SRV_CTR_ADJ_RUN' ) ).
    applications = VALUE #( sign = 'I' option = 'CP' ( low = 'TEST_*' ) ( low = 'DEMO_*' ) ).

    IF lock( ) = abap_false.
      out->write( `A PRC test run is active - run this again when it has finished. Nothing deleted.` ).
      RETURN.
    ENDIF.

    " Runs of the applications and of the objects of the processes
    SELECT uuid FROM zprc_run WHERE app_name IN @applications INTO TABLE @runs.
    SELECT DISTINCT run_uuid FROM zprc_proc_object
      WHERE process_name IN @processes
        AND run_uuid     <> @( VALUE sysuuid_x16( ) )
      APPENDING TABLE @runs.
    SORT runs BY table_line.
    DELETE ADJACENT DUPLICATES FROM runs COMPARING table_line.

    " Objects of the processes, of these runs, and notifications of these runs
    SELECT uuid, process_name FROM zprc_proc_object
      WHERE process_name IN @processes
      INTO TABLE @objects.
    IF runs IS NOT INITIAL.
      SELECT uuid, process_name FROM zprc_proc_object
        FOR ALL ENTRIES IN @runs
        WHERE run_uuid = @runs-table_line
        APPENDING TABLE @objects.
      SELECT uuid, process_name FROM zprc_proc_object
        FOR ALL ENTRIES IN @runs
        WHERE process_name              = @co_run_notification
          AND ext_processed_object_uuid = @runs-table_line
        APPENDING TABLE @objects.
    ENDIF.
    " ... and notifications of runs that no longer exist
    SELECT o~uuid, o~process_name FROM zprc_proc_object AS o
      LEFT OUTER JOIN zprc_run AS r ON r~uuid = o~ext_processed_object_uuid
      WHERE o~process_name = @co_run_notification
        AND r~uuid IS NULL
      APPENDING TABLE @objects.
    SORT objects BY uuid.
    DELETE ADJACENT DUPLICATES FROM objects COMPARING uuid.

    delete_objects( objects ).
    delete_runs( runs ).
    COMMIT WORK.

    out->write( |Deleted: { lines( objects ) } processed objects, { lines( runs ) } runs| ).
    LOOP AT objects INTO DATA(object) GROUP BY object-process_name INTO DATA(process).
      out->write( |  { process }: { REDUCE i( INIT n = 0 FOR o IN GROUP process NEXT n = n + 1 ) }| ).
    ENDLOOP.
  ENDMETHOD.


  METHOD lock.
    DATA(test_run_lock) = co_test_run_lock.
    TRY.
        cl_abap_lock_object_factory=>get_instance( iv_name = CONV #( zcl_prc_object_lock=>co_lock_object )
          )->enqueue( it_parameter = VALUE #( ( name = 'UUID' value = REF #( test_run_lock ) ) )
                      _scope       = '1' ).
        r_locked = abap_true.
      CATCH cx_abap_foreign_lock.
        r_locked = abap_false.
      CATCH cx_abap_lock_failure.
        " Lock object not available: run without protection
        r_locked = abap_true.
    ENDTRY.
  ENDMETHOD.


  METHOD delete_objects.
    DATA uuids TYPE RANGE OF sysuuid_x16.

    LOOP AT i_objects INTO DATA(object).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = object-uuid ) TO uuids.
      IF lines( uuids ) = co_package_size OR sy-tabix = lines( i_objects ).
        DELETE FROM zprc_proc_msg    WHERE processed_object_uuid IN @uuids.
        DELETE FROM zprc_proc_step   WHERE processed_object_uuid IN @uuids.
        DELETE FROM zprc_proc_object WHERE uuid                  IN @uuids.
        CLEAR uuids.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD delete_runs.
    DATA uuids TYPE RANGE OF sysuuid_x16.

    LOOP AT i_runs INTO DATA(run).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = run ) TO uuids.
      IF lines( uuids ) = co_package_size OR sy-tabix = lines( i_runs ).
        DELETE FROM zprc_run_params WHERE job_uuid IN @uuids.
        DELETE FROM zprc_run        WHERE uuid     IN @uuids.
        CLEAR uuids.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
