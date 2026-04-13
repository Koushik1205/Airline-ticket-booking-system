CLASS lhc_AirlineBookingHdr DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR AirlineBookingHdr RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR AirlineBookingHdr RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE AirlineBookingHdr.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE AirlineBookingHdr.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE AirlineBookingHdr.

    METHODS read FOR READ
      IMPORTING keys FOR READ AirlineBookingHdr RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK AirlineBookingHdr.

    METHODS rba_Bookingitem FOR READ
      IMPORTING keys_rba FOR READ AirlineBookingHdr\_Bookingitem FULL result_requested RESULT result LINK association_links.

    METHODS cba_Bookingitem FOR MODIFY
      IMPORTING entities_cba FOR CREATE AirlineBookingHdr\_Bookingitem.
ENDCLASS.

CLASS lhc_AirlineBookingHdr IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD lock.
    " Implementation for locking active/draft instances usually goes here
  ENDMETHOD.

  "---------------------------------------------------------------------
  " CREATE: Handle Header Creation
  "---------------------------------------------------------------------
  METHOD create.
    DATA: ls_booking_hdr TYPE zcit_bkhdr_am022.
    DATA(lo_util) = zcl_bkutil_am022=>get_instance( ).

    LOOP AT entities INTO DATA(ls_entity).
      ls_booking_hdr = CORRESPONDING #( ls_entity MAPPING FROM ENTITY ).

      " Check for duplicates in active table
      SELECT SINGLE FROM zcit_bkhdr_am022
        FIELDS bookingid WHERE bookingid = @ls_booking_hdr-bookingid
        INTO @DATA(lv_dummy).

      IF sy-subrc NE 0.
        lo_util->set_hdr_value(
          EXPORTING im_booking_hdr = ls_booking_hdr
          IMPORTING ex_created     = DATA(lv_created) ).

        IF lv_created = abap_true.
          " Map the CID to the Key for the framework
          INSERT VALUE #( %cid = ls_entity-%cid
                          bookingid = ls_booking_hdr-bookingid ) INTO TABLE mapped-airlinebookinghdr.

          APPEND VALUE #( %cid = ls_entity-%cid
                          %msg = new_message( id = 'ZCIT_AIR_MSG_AM022' number = 001
                                              v1 = 'Booking Created Successfully'
                                              severity = if_abap_behv_message=>severity-success ) )
                 TO reported-airlinebookinghdr.
        ENDIF.
      ELSE.
        APPEND VALUE #( %cid = ls_entity-%cid ) TO failed-airlinebookinghdr.
        APPEND VALUE #( %cid = ls_entity-%cid
                        %msg = new_message( id = 'ZCIT_AIR_MSG_AM022' number = 002
                                            v1 = 'Duplicate Booking ID'
                                            severity = if_abap_behv_message=>severity-error ) )
               TO reported-airlinebookinghdr.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  "---------------------------------------------------------------------
  " UPDATE: Handle Header Updates
  "---------------------------------------------------------------------
  METHOD update.
    DATA: ls_booking_hdr TYPE zcit_bkhdr_am022.
    DATA(lo_util) = zcl_bkutil_am022=>get_instance( ).

    LOOP AT entities INTO DATA(ls_entity).
      ls_booking_hdr = CORRESPONDING #( ls_entity MAPPING FROM ENTITY ).

      " Verify existence before update
      SELECT SINGLE FROM zcit_bkhdr_am022
        FIELDS bookingid WHERE bookingid = @ls_booking_hdr-bookingid
        INTO @DATA(lv_exists).

      IF sy-subrc = 0.
        lo_util->set_hdr_value(
          EXPORTING im_booking_hdr = ls_booking_hdr
          IMPORTING ex_created     = DATA(lv_updated) ).

        IF lv_updated = abap_true.
          APPEND VALUE #( %tky = ls_entity-%tky
                          %msg = new_message( id = 'ZCIT_AIR_MSG_AM022' number = 001
                                              v1 = 'Booking Updated Successfully'
                                              severity = if_abap_behv_message=>severity-success ) )
                 TO reported-airlinebookinghdr.
        ENDIF.
      ELSE.
        APPEND VALUE #( %tky = ls_entity-%tky ) TO failed-airlinebookinghdr.
        APPEND VALUE #( %tky = ls_entity-%tky
                        %msg = new_message( id = 'ZCIT_AIR_MSG_AM022' number = 003
                                            v1 = 'Booking Not Found!'
                                            severity = if_abap_behv_message=>severity-error ) )
               TO reported-airlinebookinghdr.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  "---------------------------------------------------------------------
  " DELETE: Handle Deletion
  "---------------------------------------------------------------------
  METHOD delete.
    DATA(lo_util) = zcl_bkutil_am022=>get_instance( ).

    LOOP AT keys INTO DATA(ls_key).
      lo_util->set_hdr_t_deletion( EXPORTING im_booking_doc = VALUE #( bookingid = ls_key-bookingid ) ).
      lo_util->set_hdr_deletion_flag( EXPORTING im_bk_delete = abap_true ).

      APPEND VALUE #( %tky = ls_key-%tky
                      %msg = new_message( id = 'ZCIT_AIR_MSG_AM022' number = 001
                                          v1 = 'Booking Deleted Successfully'
                                          severity = if_abap_behv_message=>severity-success ) )
             TO reported-airlinebookinghdr.
    ENDLOOP.
  ENDMETHOD.

  "---------------------------------------------------------------------
  " READ: Standard implementation for Unmanaged
  "---------------------------------------------------------------------
  METHOD read.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE FROM zcit_bkhdr_am022 FIELDS *
        WHERE bookingid = @ls_key-bookingid
        INTO @DATA(ls_hdr).
      IF sy-subrc = 0.
        APPEND CORRESPONDING #( ls_hdr ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  "---------------------------------------------------------------------
  " RBA: Read Booking Items by Association
  "---------------------------------------------------------------------
  METHOD rba_Bookingitem.
    LOOP AT keys_rba INTO DATA(ls_key).
      SELECT FROM zcit_bkitm_am022 FIELDS *
        WHERE bookingid = @ls_key-bookingid
        INTO TABLE @DATA(lt_items).

      LOOP AT lt_items INTO DATA(ls_item).
        APPEND CORRESPONDING #( ls_item ) TO result.
        APPEND VALUE #( source-bookingid = ls_key-bookingid
                        target-bookingid = ls_item-bookingid
                        target-itemnumber = ls_item-itemnumber )
               TO association_links.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  "---------------------------------------------------------------------
  " CBA: Create Booking Item by Association
  "---------------------------------------------------------------------
  METHOD cba_Bookingitem.
    DATA: ls_booking_itm TYPE zcit_bkitm_am022.
    DATA(lo_util) = zcl_bkutil_am022=>get_instance( ).

    LOOP AT entities_cba INTO DATA(ls_entity_cba).
      LOOP AT ls_entity_cba-%target INTO DATA(ls_target).
        ls_booking_itm = CORRESPONDING #( ls_target MAPPING FROM ENTITY ).

        " Ensure the child is linked to the parent ID
        ls_booking_itm-bookingid = ls_entity_cba-bookingid.

        SELECT SINGLE FROM zcit_bkitm_am022
          FIELDS bookingid
          WHERE bookingid  = @ls_booking_itm-bookingid
            AND itemnumber = @ls_booking_itm-itemnumber
          INTO @DATA(lv_itm_exists).

        IF sy-subrc NE 0.
          lo_util->set_itm_value(
            EXPORTING im_booking_itm = ls_booking_itm
            IMPORTING ex_created     = DATA(lv_created) ).

          IF lv_created = abap_true.
            " FIX: Changed bookingitem to airlinebookingitm
            INSERT VALUE #( %cid       = ls_target-%cid
                            bookingid  = ls_booking_itm-bookingid
                            itemnumber = ls_booking_itm-itemnumber )
                   INTO TABLE mapped-airlinebookingitm.
          ENDIF.
        ELSE.
          " FIX: Changed bookingitem to airlinebookingitm
          APPEND VALUE #( %cid = ls_target-%cid ) TO failed-airlinebookingitm.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
