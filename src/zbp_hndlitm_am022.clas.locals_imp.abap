CLASS lhc_AirlineBookingItm DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE AirlineBookingItm.
    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE AirlineBookingItm.
    METHODS read FOR READ
      IMPORTING keys FOR READ AirlineBookingItm RESULT result.
    METHODS rba_Bookingheader FOR READ
      IMPORTING keys_rba FOR READ AirlineBookingItm\_Bookingheader
      FULL result_requested RESULT result LINK association_links.
ENDCLASS.

CLASS lhc_AirlineBookingItm IMPLEMENTATION.

  "---------------------------------------------------------------------
  " UPDATE: Buffer changes to a flight segment item
  "---------------------------------------------------------------------
  METHOD update.
    DATA: ls_booking_itm TYPE zcit_bkitm_am022.
    DATA(lo_util) = zcl_bkutil_am022=>get_instance( ).

    LOOP AT entities INTO DATA(ls_entity).
      ls_booking_itm = CORRESPONDING #( ls_entity MAPPING FROM ENTITY ).

      IF ls_booking_itm-bookingid IS NOT INITIAL AND ls_booking_itm-itemnumber IS NOT INITIAL.

        " Check if the record exists in the active table
        SELECT SINGLE FROM zcit_bkitm_am022
          FIELDS bookingid
          WHERE bookingid  = @ls_booking_itm-bookingid
            AND itemnumber = @ls_booking_itm-itemnumber
          INTO @DATA(lv_exists).

        IF sy-subrc EQ 0.
          lo_util->set_itm_value(
            EXPORTING im_booking_itm = ls_booking_itm
            IMPORTING ex_created     = DATA(lv_updated) ).

          IF lv_updated EQ abap_true.
            " Success Message
            APPEND VALUE #( %tky = ls_entity-%tky
                            %msg = new_message( id = 'ZCIT_AIR_MSG_AM022' number = 001
                                                v1 = 'Flight Segment Updated Successfully'
                                                severity = if_abap_behv_message=>severity-success ) )
                   TO reported-airlinebookingitm.
          ENDIF.
        ELSE.
          " Record not found
          APPEND VALUE #( %tky = ls_entity-%tky ) TO failed-airlinebookingitm.
          APPEND VALUE #( %tky = ls_entity-%tky
                          %msg = new_message( id = 'ZCIT_AIR_MSG_AM022' number = 003
                                              v1 = 'Flight Segment Not Found!'
                                              severity = if_abap_behv_message=>severity-error ) )
                 TO reported-airlinebookingitm.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  "---------------------------------------------------------------------
  " DELETE: Mark a specific flight segment for deletion
  "---------------------------------------------------------------------
  METHOD delete.
    DATA(lo_util) = zcl_bkutil_am022=>get_instance( ).

    LOOP AT keys INTO DATA(ls_key).
      " Pass the key to the utility class for buffering deletion
      lo_util->set_itm_t_deletion(
        EXPORTING im_booking_itm_info = VALUE #( bookingid  = ls_key-bookingid
                                                 itemnumber = ls_key-itemnumber ) ).

      " Success Message
      APPEND VALUE #( %tky = ls_key-%tky
                      %msg = new_message( id = 'ZCIT_AIR_MSG_AM022' number = 001
                                          v1 = 'Flight Segment Deleted Successfully'
                                          severity = if_abap_behv_message=>severity-success ) )
             TO reported-airlinebookingitm.
    ENDLOOP.
  ENDMETHOD.

  "---------------------------------------------------------------------
  " READ: Implementation for direct item fetch
  "---------------------------------------------------------------------
  METHOD read.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE FROM zcit_bkitm_am022 FIELDS *
        WHERE bookingid  = @ls_key-bookingid
          AND itemnumber = @ls_key-itemnumber
        INTO @DATA(ls_itm).
      IF sy-subrc = 0.
        APPEND CORRESPONDING #( ls_itm ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  "---------------------------------------------------------------------
  " RBA: Read parent header from an item
  "---------------------------------------------------------------------
  METHOD rba_Bookingheader.
    " Typically used to navigate back to the Header from the Item
    LOOP AT keys_rba INTO DATA(ls_key).
      SELECT SINGLE FROM zcit_bkhdr_am022 FIELDS *
        WHERE bookingid = @ls_key-bookingid
        INTO @DATA(ls_hdr).
      IF sy-subrc = 0.
        APPEND CORRESPONDING #( ls_hdr ) TO result.
        APPEND VALUE #( source-bookingid  = ls_key-bookingid
                        source-itemnumber = ls_key-itemnumber
                        target-bookingid  = ls_hdr-bookingid )
               TO association_links.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
