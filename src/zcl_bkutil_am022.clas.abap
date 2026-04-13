CLASS zcl_bkutil_am022 DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_booking_hdr,
             bookingid TYPE zcit_bkid_am022,
           END OF ty_booking_hdr,
           BEGIN OF ty_booking_itm,
             bookingid  TYPE zcit_bkid_am022,
             itemnumber TYPE int2,
           END OF ty_booking_itm.
    TYPES: tt_booking_hdr TYPE STANDARD TABLE OF ty_booking_hdr,
           tt_booking_itm TYPE STANDARD TABLE OF ty_booking_itm.

    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_bkutil_am022.

    METHODS:
      set_hdr_value
        IMPORTING im_booking_hdr TYPE zcit_bkhdr_am022
        EXPORTING ex_created     TYPE abap_boolean,
      get_hdr_value
        EXPORTING ex_booking_hdr TYPE zcit_bkhdr_am022,
      set_itm_value
        IMPORTING im_booking_itm TYPE zcit_bkitm_am022
        EXPORTING ex_created     TYPE abap_boolean,
      get_itm_value
        EXPORTING ex_booking_itm TYPE zcit_bkitm_am022,
      set_hdr_t_deletion
        IMPORTING im_booking_doc TYPE ty_booking_hdr,
      set_itm_t_deletion
        IMPORTING im_booking_itm_info TYPE ty_booking_itm,
      get_hdr_t_deletion
        EXPORTING ex_booking_docs TYPE tt_booking_hdr,
      get_itm_t_deletion
        EXPORTING ex_booking_info TYPE tt_booking_itm,
      set_hdr_deletion_flag
        IMPORTING im_bk_delete   TYPE abap_boolean,
      get_deletion_flags
        EXPORTING ex_bk_hdr_del  TYPE abap_boolean,
      cleanup_buffer.

  PRIVATE SECTION.
    CLASS-DATA: gs_booking_hdr_buff    TYPE zcit_bkhdr_am022,
                gs_booking_itm_buff    TYPE zcit_bkitm_am022,
                gt_booking_hdr_t_buff  TYPE tt_booking_hdr,
                gt_booking_itm_t_buff  TYPE tt_booking_itm,
                gv_bk_delete           TYPE abap_boolean.
    CLASS-DATA mo_instance TYPE REF TO zcl_bkutil_am022.
ENDCLASS.

CLASS zcl_bkutil_am022 IMPLEMENTATION.
  METHOD get_instance.
    IF mo_instance IS INITIAL.
      CREATE OBJECT mo_instance.
    ENDIF.
    ro_instance = mo_instance.
  ENDMETHOD.

  METHOD set_hdr_value.
    IF im_booking_hdr-bookingid IS NOT INITIAL.
      gs_booking_hdr_buff = im_booking_hdr.
      ex_created = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD get_hdr_value.
    ex_booking_hdr = gs_booking_hdr_buff.
  ENDMETHOD.

  METHOD set_itm_value.
    IF im_booking_itm IS NOT INITIAL.
      gs_booking_itm_buff = im_booking_itm.
      ex_created = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD get_itm_value.
    ex_booking_itm = gs_booking_itm_buff.
  ENDMETHOD.

  METHOD set_hdr_t_deletion.
    APPEND im_booking_doc TO gt_booking_hdr_t_buff.
  ENDMETHOD.

  METHOD set_itm_t_deletion.
    APPEND im_booking_itm_info TO gt_booking_itm_t_buff.
  ENDMETHOD.

  METHOD get_hdr_t_deletion.
    ex_booking_docs = gt_booking_hdr_t_buff.
  ENDMETHOD.

  METHOD get_itm_t_deletion.
    ex_booking_info = gt_booking_itm_t_buff.
  ENDMETHOD.

  METHOD set_hdr_deletion_flag.
    gv_bk_delete = im_bk_delete.
  ENDMETHOD.

  METHOD get_deletion_flags.
    ex_bk_hdr_del = gv_bk_delete.
  ENDMETHOD.

  METHOD cleanup_buffer.
    CLEAR: gs_booking_hdr_buff, gs_booking_itm_buff,
           gt_booking_hdr_t_buff, gt_booking_itm_t_buff, gv_bk_delete.
  ENDMETHOD.
ENDCLASS.

