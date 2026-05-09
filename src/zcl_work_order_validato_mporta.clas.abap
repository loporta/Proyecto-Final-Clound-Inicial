CLASS zcl_work_order_validato_mporta DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS: validate_create_order IMPORTING iv_customer_id   TYPE ze_customer_id_mporta
                                             iv_technician_id TYPE ze_technician_id_mporta
                                             iv_priority      TYPE ze_priority_mporta
                                   RETURNING VALUE(rv_valid)  TYPE abap_bool,

      validate_update_order IMPORTING iv_work_order_id TYPE ze_work_order_id_mporta
                                      iv_status        TYPE ze_status_mporta
                            RETURNING VALUE(rv_valid)  TYPE abap_bool,

      validate_delete_order IMPORTING iv_work_order_id TYPE ze_work_order_id_mporta
                                      iv_status        TYPE ze_status_mporta
                            RETURNING VALUE(rv_valid)  TYPE abap_bool,

      validate_status_and_priority IMPORTING iv_status       TYPE ze_status_mporta
                                             iv_priority     TYPE ze_priority_mporta
                                   RETURNING VALUE(rv_valid) TYPE abap_bool.

  PRIVATE SECTION.
    CONSTANTS: c_valid_status_pe  TYPE string VALUE 'PE',
               c_valid_status_co  TYPE string VALUE 'CO',
               c_valid_priority_a TYPE string VALUE 'A',
               c_valid_priority_b TYPE string VALUE 'B'.

    METHODS:
      check_customer_exists IMPORTING iv_customer_id   TYPE ze_customer_id_mporta
                            RETURNING VALUE(rv_exists) TYPE abap_bool,

      check_technician_exists IMPORTING iv_technician_id TYPE ze_technician_id_mporta
                              RETURNING VALUE(rv_exists) TYPE abap_bool,

      check_order_exists IMPORTING iv_work_order_id TYPE ze_work_order_id_mporta
                         RETURNING VALUE(rv_exists) TYPE abap_bool,

      check_order_history IMPORTING iv_work_order_id TYPE ze_work_order_id_mporta
                          RETURNING VALUE(rv_exists) TYPE abap_bool.

ENDCLASS.

CLASS zcl_work_order_validato_mporta IMPLEMENTATION.

  METHOD validate_create_order.
    . DATA(lv_customer_exists) = check_customer_exists( iv_customer_id ).

    IF lv_customer_exists IS INITIAL.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    DATA(lv_technician_exists) = check_technician_exists( iv_technician_id ).

    IF lv_technician_exists IS INITIAL.
      rv_valid = abap_false.
      RETURN.

    ENDIF.

    IF iv_priority NE c_valid_priority_b OR iv_priority NE c_valid_priority_a.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    rv_valid = abap_true.

  ENDMETHOD.

  METHOD validate_update_order.

    DATA(lv_order_exists) = check_order_exists( iv_work_order_id ).

    IF lv_order_exists IS INITIAL.
      rv_valid = abap_false.
      RETURN.

    ENDIF.

    IF iv_status NE c_valid_status_pe OR iv_status NE c_valid_status_co.
      rv_valid = abap_false.
      RETURN.

    ENDIF.

    rv_valid = abap_true.

  ENDMETHOD.

  METHOD validate_delete_order.

    DATA(lv_order_exists) = check_order_exists( iv_work_order_id ).

    IF lv_order_exists IS INITIAL.
      rv_valid = abap_false.
      RETURN.

    ENDIF.

    IF iv_status NE c_valid_status_pe.
      rv_valid = abap_false.
      RETURN.

    ENDIF.

    DATA(lv_has_history) = check_order_history( iv_work_order_id ).

    IF lv_has_history IS INITIAL.
      rv_valid = abap_false.
      RETURN.

    ENDIF.

    rv_valid = abap_true.

  ENDMETHOD.

  METHOD validate_status_and_priority.

    IF iv_status NE c_valid_status_pe OR iv_status NE c_valid_status_co.
      rv_valid = abap_false.
      RETURN.

    ENDIF.

    IF iv_priority NE c_valid_priority_b OR iv_priority NE c_valid_priority_a.
      rv_valid = abap_false.
      RETURN.

    ENDIF.

    rv_valid = abap_true.
  ENDMETHOD.

  METHOD check_customer_exists.

    TRY.
        SELECT SINGLE  customer_id
                 FROM ztworkordermport
                WHERE customer_id = @iv_customer_id
                 INTO @DATA(lv_existe).

      CATCH cx_sy_open_sql_db INTO DATA(lx_error).
        IF sy-subrc <> 0.
          rv_exists = abap_false.
        ENDIF.
    ENDTRY.
    IF sy-subrc = 0.
      rv_exists = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD check_order_exists.

    SELECT SINGLE  work_order_id
             FROM ztworkordermport
            WHERE work_order_id = @iv_work_order_id
             INTO @DATA(lv_existe).

    IF sy-subrc = 0.
      rv_exists = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD check_order_history.

    SELECT SINGLE  work_order_id
            FROM ztworkhistmporta
            WHERE work_order_id  = @iv_work_order_id
            INTO @DATA(lv_existe).
    IF sy-subrc = 0.
      rv_exists = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD check_technician_exists.

    SELECT SINGLE  technician_id
            FROM ztworkordermport
            WHERE technician_id  = @iv_technician_id
            INTO @DATA(lv_existe).
    IF sy-subrc = 0.
      rv_exists = abap_true.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
