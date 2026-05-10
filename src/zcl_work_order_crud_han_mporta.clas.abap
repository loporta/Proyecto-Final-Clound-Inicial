CLASS zcl_work_order_crud_han_mporta DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_datos,
        lw_ztworkordermport TYPE ztworkordermport,
      END OF ty_datos.

    TYPES: ty_ztworkordermport TYPE TABLE OF ztworkordermport.

    METHODS: create_work_order IMPORTING lw_ztworkordermport TYPE ty_datos
                               CHANGING  gt_ztworkordermport TYPE ty_ztworkordermport
                                         lv_mensaje          TYPE string,

      read_work_order   IMPORTING lw_ztworkordermport TYPE  ty_datos
                        CHANGING  gt_ztworkordermport TYPE ty_ztworkordermport
                                  lv_mensaje          TYPE string,

      update_work_order IMPORTING lw_ztworkordermport TYPE ty_datos
                        CHANGING  gt_ztworkordermport TYPE ty_ztworkordermport
                                  lv_mensaje          TYPE string,

      delete_work_order IMPORTING lw_ztworkordermport TYPE ty_datos
                        CHANGING  gt_ztworkordermport TYPE ty_ztworkordermport
                                  lv_mensaje          TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.




CLASS zcl_work_order_crud_han_mporta IMPLEMENTATION.
  METHOD create_work_order.

    DATA: lo_class TYPE REF TO zcl_work_order_validato_mporta.

    CREATE OBJECT lo_class.

*AUTHORITY-CHECK OBJECT 'ZCH_MPORTA'
*ID 'ZCH_MPORTA' FIELD lw_ztworkordermport-lw_ztworkordermport-technician_id
*ID 'ACTVT'  Field '01'.

    DATA(lv_existe) = lo_class->validate_create_order( iv_customer_id   = lw_ztworkordermport-lw_ztworkordermport-customer_id
                                                       iv_priority      = lw_ztworkordermport-lw_ztworkordermport-priority
                                                       iv_technician_id = lw_ztworkordermport-lw_ztworkordermport-technician_id ).
    DATA(lv_existe_technician_id) = lo_class->check_technical_exists( iv_technician_id = lw_ztworkordermport-lw_ztworkordermport-technician_id ).

    IF lv_existe = abap_false AND lv_existe_technician_id = abap_true.

      TRY.
          INSERT ztworkordermport FROM @( VALUE #(  work_order_id = lw_ztworkordermport-lw_ztworkordermport-work_order_id
                                                    technician_id = lw_ztworkordermport-lw_ztworkordermport-technician_id
                                                    customer_id   = lw_ztworkordermport-lw_ztworkordermport-customer_id
                                                    creation_date = lw_ztworkordermport-lw_ztworkordermport-creation_date
                                                    status        = lw_ztworkordermport-lw_ztworkordermport-status
                                                    priority      = lw_ztworkordermport-lw_ztworkordermport-priority
                                                    description   = lw_ztworkordermport-lw_ztworkordermport-description
                                                       ) ).
          IF sy-subrc EQ 0.
            TRY.
                INSERT  ztworkhistmporta FROM @( VALUE #( history_id    = lw_ztworkordermport-lw_ztworkordermport-work_order_id
                                                          work_order_id = lw_ztworkordermport-lw_ztworkordermport-work_order_id

                                  modification_date  = cl_abap_context_info=>get_system_date( )
                                  change_description = 'El registro se modifico' ) ).
              CATCH cx_sy_open_sql_db INTO DATA(lx_error).
                lv_mensaje = lx_error->get_text( ).
                ROLLBACK WORK.
                RETURN.
            ENDTRY.
            IF sy-subrc = 0.
              COMMIT WORK AND WAIT.
              TRY.
                  SELECT FROM ztworkordermport
                       FIELDS client, creation_date, customer_id, description, priority, status, technician_id, work_order_id
                         INTO CORRESPONDING FIELDS OF TABLE @gt_ztworkordermport.
                CATCH cx_sy_open_sql_db INTO lx_error.
                  lv_mensaje = lx_error->get_text( ).
                  ROLLBACK WORK.
                  RETURN.
              ENDTRY.
            ELSE.

              lv_mensaje = 'Error al insertar'.
              CLEAR: gt_ztworkordermport.
              ROLLBACK WORK.
              RETURN.
            ENDIF.
          ELSE.
            lv_mensaje = 'Error al insertar'.
            CLEAR: gt_ztworkordermport.
            ROLLBACK WORK.
            RETURN.
          ENDIF.
        CATCH cx_sy_open_sql_db INTO lx_error.
          lv_mensaje = lx_error->get_text( ).
          CLEAR: gt_ztworkordermport.
          ROLLBACK WORK.
          RETURN.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD delete_work_order.

    DATA: lo_class TYPE REF TO zcl_work_order_validato_mporta.

    CREATE OBJECT lo_class.

*AUTHORITY-CHECK OBJECT 'ZCH_MPORTA'
*ID 'ZCH_MPORTA' FIELD lw_ztworkordermport-lw_ztworkordermport-technician_id
*ID 'ACTVT'  Field '06'.

    DATA(lv_existe) = lo_class->validate_delete_order( iv_status        =  lw_ztworkordermport-lw_ztworkordermport-status
                                                       iv_work_order_id =  lw_ztworkordermport-lw_ztworkordermport-work_order_id ).

    IF lv_existe = abap_false.
      TRY.
          DELETE ztworkordermport FROM TABLE @( VALUE #( (  work_order_id = lw_ztworkordermport-lw_ztworkordermport-work_order_id
                                                            technician_id = lw_ztworkordermport-lw_ztworkordermport-technician_id
                                                            customer_id   = lw_ztworkordermport-lw_ztworkordermport-customer_id ) ) ).
          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.
            TRY.
                SELECT FROM ztworkordermport
                     FIELDS client, creation_date, customer_id, description, priority, status, technician_id, work_order_id
                       INTO CORRESPONDING FIELDS OF TABLE @gt_ztworkordermport.
              CATCH cx_sy_open_sql_db INTO DATA(lx_error).
                lv_mensaje = lx_error->get_text( ).
                ROLLBACK WORK.
                RETURN.
            ENDTRY.
          ELSE.
            lv_mensaje = 'Error al borrar'.
            ROLLBACK WORK.
            RETURN.
          ENDIF.
        CATCH cx_sy_open_sql_db INTO lx_error.
          lv_mensaje = lx_error->get_text( ).
          ROLLBACK WORK.
          RETURN.
      ENDTRY.
    ELSE.
      lv_mensaje = 'Error al borrar'.
      ROLLBACK WORK.
    ENDIF.
  ENDMETHOD.

  METHOD read_work_order.
*AUTHORITY-CHECK OBJECT 'ZCH_MPORTA'
*ID 'ZCH_MPORTA' FIELD lw_ztworkordermport-lw_ztworkordermport-technician_id
*ID 'ACTVT'  Field '03'.
    TRY.
        SELECT FROM ztworkordermport
        FIELDS client, creation_date, customer_id, description, priority, status, technician_id, work_order_id
        WHERE work_order_id = @lw_ztworkordermport-lw_ztworkordermport-work_order_id
          AND technician_id = @lw_ztworkordermport-lw_ztworkordermport-technician_id
          AND customer_id   = @lw_ztworkordermport-lw_ztworkordermport-customer_id
          INTO CORRESPONDING FIELDS OF TABLE @gt_ztworkordermport.
      CATCH cx_sy_open_sql_db INTO DATA(lx_error).
        lv_mensaje = lx_error->get_text( ).
    ENDTRY.
  ENDMETHOD.


  METHOD update_work_order.

*AUTHORITY-CHECK OBJECT 'ZCH_MPORTA'
*ID 'ZCH_MPORTA' FIELD lw_ztworkordermport-lw_ztworkordermport-technician_id
*ID 'ACTVT'  Field '02'.
    DATA: lo_class TYPE REF TO zcl_work_order_validato_mporta.

    CREATE OBJECT lo_class.

    DATA(lv_existe) = lo_class->validate_update_order( iv_status        = lw_ztworkordermport-lw_ztworkordermport-status
                                                       iv_work_order_id = lw_ztworkordermport-lw_ztworkordermport-work_order_id ).

    DATA(lv_campos_exiten) = lo_class->validate_status_and_priority( iv_priority = lw_ztworkordermport-lw_ztworkordermport-priority
                                                                     iv_status   = lw_ztworkordermport-lw_ztworkordermport-status ) .

    IF lv_existe = abap_true AND lv_campos_exiten = abap_true.

      TRY.
          UPDATE ztworkordermport FROM @lw_ztworkordermport-lw_ztworkordermport.

          IF sy-subrc = 0.
            COMMIT WORK AND WAIT.
          ENDIF.
        CATCH cx_sy_open_sql_db INTO DATA(lx_error).
          lv_mensaje = lx_error->get_text( ).
          CLEAR: gt_ztworkordermport.
          ROLLBACK WORK.
          RETURN.
      ENDTRY.

    ENDIF.

    TRY.
        SELECT FROM ztworkordermport
              FIELDS client, creation_date, customer_id, description, priority, status, technician_id, work_order_id
                INTO CORRESPONDING FIELDS OF TABLE @gt_ztworkordermport.
      CATCH cx_sy_open_sql_db INTO lx_error.
        lv_mensaje = lx_error->get_text( ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
