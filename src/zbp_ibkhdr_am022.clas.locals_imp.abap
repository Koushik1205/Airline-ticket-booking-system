CLASS lsc_ZCIT_IBKHDR_AM022 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize          REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save              REDEFINITION.
    METHODS cleanup           REDEFINITION.
    METHODS cleanup_finalize  REDEFINITION.
ENDCLASS.

CLASS lsc_ZCIT_IBKHDR_AM022 IMPLEMENTATION.

  METHOD finalize.
    "Called before save - use for final validations or derivations
  ENDMETHOD.

  METHOD check_before_save.
    "Called to check data consistency before the actual save
  ENDMETHOD.

  "-----------------------------------------------------------------------
  " SAVE: Read from buffer and execute DB operations (MODIFY / DELETE)
  "-----------------------------------------------------------------------
  METHOD save.
    DATA(lo_util) = zcl_bkutil_am022=>get_instance( ).

    "Retrieve all buffered data
    lo_util->get_hdr_value(
      IMPORTING ex_booking_hdr = DATA(ls_booking_hdr) ).
    lo_util->get_itm_value(
      IMPORTING ex_booking_itm = DATA(ls_booking_itm) ).
    lo_util->get_hdr_t_deletion(
      IMPORTING ex_booking_docs = DATA(lt_booking_headers) ).
    lo_util->get_itm_t_deletion(
      IMPORTING ex_booking_info = DATA(lt_booking_items) ).
    lo_util->get_deletion_flags(
      IMPORTING ex_bk_hdr_del = DATA(lv_bk_hdr_del) ).

    "1. Save / Update Booking Header
    IF ls_booking_hdr IS NOT INITIAL.
      MODIFY zcit_bkhdr_am022 FROM @ls_booking_hdr.
    ENDIF.

    "2. Save / Update Booking Item (Flight Segment)
    IF ls_booking_itm IS NOT INITIAL.
      MODIFY zcit_bkitm_am022 FROM @ls_booking_itm.
    ENDIF.

    "3. Handle Deletions
    IF lv_bk_hdr_del = abap_true.
      "Full booking deletion: remove header AND all associated items
      LOOP AT lt_booking_headers INTO DATA(ls_del_hdr).
        DELETE FROM zcit_bkhdr_am022
          WHERE bookingid = @ls_del_hdr-bookingid.
        DELETE FROM zcit_bkitm_am022
          WHERE bookingid = @ls_del_hdr-bookingid.
      ENDLOOP.
    ELSE.
      "Partial deletion: remove individual headers (if any)
      LOOP AT lt_booking_headers INTO ls_del_hdr.
        DELETE FROM zcit_bkhdr_am022
          WHERE bookingid = @ls_del_hdr-bookingid.
      ENDLOOP.
      "Partial deletion: remove individual items (flight segments)
      LOOP AT lt_booking_items INTO DATA(ls_del_itm).
        DELETE FROM zcit_bkitm_am022
          WHERE bookingid  = @ls_del_itm-bookingid
            AND itemnumber = @ls_del_itm-itemnumber.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  "-----------------------------------------------------------------------
  " CLEANUP: Clear the transactional buffer after save completes
  "-----------------------------------------------------------------------
  METHOD cleanup.
    zcl_bkutil_am022=>get_instance( )->cleanup_buffer( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
    "Called after cleanup - typically empty in basic scenarios
  ENDMETHOD.
ENDCLASS.
