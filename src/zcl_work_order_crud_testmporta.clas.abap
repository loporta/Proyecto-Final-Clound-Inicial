CLASS zcl_work_order_crud_testmporta DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_datos,
        lw_ztworkordermport TYPE ztworkordermport,
        lw_ztcustomermporta TYPE ztcustomermporta,
        lw_zttechnicimporta TYPE zttechnicimporta,
      END OF ty_datos.

    TYPES: ty_ztworkordermport TYPE TABLE OF ztworkordermport.

    INTERFACES: if_oo_adt_classrun.

    METHODS:
      test_create_work_order IMPORTING lw_ztworkordermport TYPE ty_datos
                             CHANGING  gt_data             TYPE ty_ztworkordermport
                                       lv_mensaje          TYPE string,

      test_read_work_order   IMPORTING lw_ztworkordermport TYPE ty_datos
                             CHANGING  gt_data             TYPE ty_ztworkordermport
                                       lv_mensaje          TYPE string,

      test_update_work_order IMPORTING lw_ztworkordermport TYPE ty_datos
                             CHANGING  gt_data             TYPE ty_ztworkordermport
                                       lv_mensaje          TYPE string,

      test_delete_work_order IMPORTING lw_ztworkordermport TYPE ty_datos
                             CHANGING  gt_data             TYPE ty_ztworkordermport
                                       lv_mensaje          TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_work_order_crud_testmporta IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA: lw_ztworkordermport TYPE ty_datos,
          gt_data             TYPE ty_ztworkordermport,
          lv_mensaje          TYPE string.

    "Se inserte el registro.

    SELECT FROM ztworkordermport
        FIELDS customer_id,
               work_order_id,
               technician_id
        INTO TABLE @DATA(gt_ultimo).
    IF sy-subrc = 0.

      SORT gt_ultimo BY work_order_id DESCENDING.
      DATA(lv_ultimo_order) = gt_ultimo[ 1 ]-work_order_id.
    ENDIF.

    lw_ztworkordermport = VALUE #( lw_ztworkordermport-customer_id   = lv_ultimo_order + 1
                                   lw_ztworkordermport-technician_id = lv_ultimo_order + 1
                                   lw_ztworkordermport-work_order_id = lv_ultimo_order + 1
                                   lw_ztworkordermport-status       = 'T'
                                   lw_ztworkordermport-priority     = 'A'
                                   lw_ztworkordermport-description  = 'Prueba 1'
                                   lw_ztworkordermport-creation_date = cl_abap_context_info=>get_system_date( )
                                   lw_zttechnicimporta-technician_id = lv_ultimo_order + 1
                                   lw_zttechnicimporta-name          = 'PORTA 1'
                                   lw_zttechnicimporta-specialty     = 'ABAP'
                                   lw_ztcustomermporta-customer_id   = lv_ultimo_order + 1
                                   lw_ztcustomermporta-name          = 'Lorena 1'
                                   lw_ztcustomermporta-address       = 'Argentina'
                                   lw_ztcustomermporta-phone         = '123456789' ) .

    IF lw_ztworkordermport  IS NOT INITIAL.
      me->test_create_work_order( EXPORTING lw_ztworkordermport = lw_ztworkordermport
                                  CHANGING  gt_data             = gt_data
                                            lv_mensaje          = lv_mensaje ).

      IF lv_mensaje IS INITIAL.
        out->Write( name = 'Se Inserto el registro tabla final' data = gt_data ).
      ELSE.
        out->write( | 'Mensaje de Error' - { lv_mensaje } | ).
      ENDIF.

    ENDIF.

    "Se lee el registro insertado.
    CLEAR: gt_data, lv_mensaje.
    me->test_read_work_order( EXPORTING lw_ztworkordermport = lw_ztworkordermport
                                CHANGING  gt_data             = gt_data
                                          lv_mensaje          = lv_mensaje ).

    IF lv_mensaje IS INITIAL.
      out->Write( name = 'Se lee la tabla' data = gt_data ).
    ELSE.
      out->write( | 'Mensaje de Error' - { lv_mensaje } | ).
    ENDIF.


    "Se  modifica el registro insertado.
    lw_ztworkordermport = VALUE #( lw_ztworkordermport-customer_id   = lv_ultimo_order + 1
                                   lw_ztworkordermport-technician_id = lv_ultimo_order + 1
                                   lw_ztworkordermport-work_order_id = lv_ultimo_order + 1
                                   lw_ztworkordermport-status       = 'T'
                                   lw_ztworkordermport-priority     = 'A'
                                   lw_ztworkordermport-description  = 'Prueba 2'
                                   lw_ztworkordermport-creation_date = cl_abap_context_info=>get_system_date( )
                                   lw_zttechnicimporta-technician_id = lv_ultimo_order + 1
                                   lw_zttechnicimporta-name          = 'PORTA 2'
                                   lw_zttechnicimporta-specialty     = 'ABAP'
                                   lw_ztcustomermporta-customer_id   = lv_ultimo_order + 1
                                   lw_ztcustomermporta-name          = 'Lorena 2'
                                   lw_ztcustomermporta-address       = 'Argentina'
                                   lw_ztcustomermporta-phone         = '123456789' ) .

    IF lw_ztworkordermport  IS NOT INITIAL.
      CLEAR: gt_data, lv_mensaje.
      me->test_update_work_order( EXPORTING lw_ztworkordermport = lw_ztworkordermport
                                  CHANGING  gt_data             = gt_data
                                            lv_mensaje          = lv_mensaje ).

      IF lv_mensaje IS INITIAL.
        out->Write( name = 'Se modifico la tabla' data = gt_data ).
      ELSE.
        out->write( | 'Mensaje de Error' - { lv_mensaje } | ).
      ENDIF.
    ENDIF.

    "Se borrra el registro insertado.

    IF lw_ztworkordermport  IS NOT INITIAL.
      CLEAR: gt_data, lv_mensaje.
      me->test_delete_work_order( EXPORTING lw_ztworkordermport = lw_ztworkordermport
                                  CHANGING  gt_data             = gt_data
                                            lv_mensaje          = lv_mensaje ).

      IF lv_mensaje IS INITIAL.
        out->Write( name = 'Se Borro el registro' data = gt_data ).
      ELSE.
        out->write( | 'Mensaje de Error' - { lv_mensaje } | ).
      ENDIF.

    ENDIF.
  ENDMETHOD.

  METHOD test_create_work_order.
    DATA cl_work_order TYPE REF TO zcl_work_order_crud_han_mporta.

    CREATE OBJECT cl_work_order.

    cl_work_order->create_work_order( EXPORTING lw_ztworkordermport = lw_ztworkordermport
                                      CHANGING  gt_ztworkordermport = gt_data
                                                lv_mensaje          = lv_mensaje ).
  ENDMETHOD.

  METHOD test_delete_work_order.
    DATA cl_work_order TYPE REF TO zcl_work_order_crud_han_mporta.

    CREATE OBJECT cl_work_order.

    cl_work_order->delete_work_order( EXPORTING lw_ztworkordermport = lw_ztworkordermport
                                      CHANGING  gt_ztworkordermport = gt_data
                                                lv_mensaje          = lv_mensaje ).

  ENDMETHOD.

  METHOD test_read_work_order.
    DATA cl_work_order TYPE REF TO zcl_work_order_crud_han_mporta.

    CREATE OBJECT cl_work_order.

    cl_work_order->read_work_order( EXPORTING lw_ztworkordermport = lw_ztworkordermport
                                    CHANGING  gt_ztworkordermport = gt_data
                                              lv_mensaje          = lv_mensaje ).
  ENDMETHOD.

  METHOD test_update_work_order.
    DATA cl_work_order TYPE REF TO zcl_work_order_crud_han_mporta.

    CREATE OBJECT cl_work_order.

    cl_work_order->update_work_order( EXPORTING lw_ztworkordermport = lw_ztworkordermport
                                      CHANGING  gt_ztworkordermport = gt_data
                                                lv_mensaje          = lv_mensaje ).
  ENDMETHOD.

ENDCLASS.
