-- Stored Procedure: spd_13_abcdesctos
-- Tipo: CRUD
-- Descripción: Alta, baja, modificación y reactivación de descuentos para cementerios. OPC: 1=alta, 2=baja, 3=modifica, 4=reactivar.
-- Generado para formulario: Descuentos
-- Fecha: 2025-08-27 14:28:10

-- PostgreSQL version of spd_13_abcdesctos
CREATE OR REPLACE FUNCTION spd_13_abcdesctos(
    v_control integer,
    v_axo integer,
    v_porc integer,
    v_usu integer,
    v_reac varchar(1),
    v_tipo_descto varchar(1),
    v_opc integer
)
RETURNS TABLE(par_ok smallint, par_observ varchar) AS $$
DECLARE
    v_exists integer;
BEGIN
    IF v_opc = 1 THEN -- Alta
        SELECT COUNT(*) INTO v_exists FROM ta_13_descpens WHERE control_rcm = v_control AND axo_descto = v_axo AND vigencia = 'V';
        IF v_exists > 0 THEN
            par_ok := 1;
            par_observ := 'Ya tiene descuento para el adeudo del año seleccionado, verifique';
            RETURN NEXT;
        END IF;
        INSERT INTO ta_13_descpens (control_rcm, axo_descto, descuento, usuario, fecha_alta, vigencia, reactivar, tipo_descto)
        VALUES (v_control, v_axo, v_porc, v_usu, CURRENT_DATE, 'V', v_reac, v_tipo_descto);
        par_ok := 0;
        par_observ := 'Descuento dado de alta correctamente';
        RETURN NEXT;
    ELSIF v_opc = 2 THEN -- Baja
        UPDATE ta_13_descpens SET vigencia = 'B', usuario_mov = v_usu, fecha_mov = CURRENT_DATE
        WHERE control_rcm = v_control AND axo_descto = v_axo AND vigencia = 'V';
        par_ok := 0;
        par_observ := 'Descuento dado de baja correctamente';
        RETURN NEXT;
    ELSIF v_opc = 3 THEN -- Modifica
        UPDATE ta_13_descpens SET descuento = v_porc, usuario_mov = v_usu, fecha_mov = CURRENT_DATE
        WHERE control_rcm = v_control AND axo_descto = v_axo AND vigencia = 'V';
        par_ok := 0;
        par_observ := 'Descuento modificado correctamente';
        RETURN NEXT;
    ELSIF v_opc = 4 THEN -- Reactivar
        UPDATE ta_13_descpens SET reactivar = 'S', usuario_mov = v_usu, fecha_mov = CURRENT_DATE
        WHERE control_rcm = v_control AND axo_descto = v_axo;
        par_ok := 0;
        par_observ := 'Descuento reactivado correctamente';
        RETURN NEXT;
    ELSE
        par_ok := 1;
        par_observ := 'Operación no soportada';
        RETURN NEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;