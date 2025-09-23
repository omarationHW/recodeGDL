-- Stored Procedure: ins_recaraseo
-- Tipo: CRUD
-- Descripción: Inserta o cancela un descuento de recargos de aseo contratado. Si par_opc=1 inserta, si par_opc=2 cancela.
-- Generado para formulario: drecgoAseo
-- Fecha: 2025-08-27 00:34:16

-- PostgreSQL stored procedure for descuentos en recargos de aseo contratado
CREATE OR REPLACE FUNCTION ins_recaraseo(
    par_control integer,
    par_axoi integer,
    par_mesi integer,
    par_axof integer,
    par_mesf integer,
    par_usuario varchar,
    par_porc integer,
    par_opc integer
) RETURNS integer AS $$
DECLARE
    v_control integer;
BEGIN
    IF par_opc = 1 THEN
        -- Alta de descuento
        INSERT INTO t34_descrecaseo (
            id_contrato, axo_ini, mes_ini, axo_fin, mes_fin, fecha_alta, usuario_alta, vigencia, porc
        ) VALUES (
            par_control, par_axoi, par_mesi, par_axof, par_mesf, NOW(), par_usuario, 'V', par_porc
        ) RETURNING id_descto INTO v_control;
        RETURN v_control;
    ELSIF par_opc = 2 THEN
        -- Cancelación de descuento
        UPDATE t34_descrecaseo
        SET fecha_baja = NOW(), usuario_baja = par_usuario, vigencia = 'C'
        WHERE id_contrato = par_control
          AND axo_ini = par_axoi AND mes_ini = par_mesi
          AND axo_fin = par_axof AND mes_fin = par_mesf
          AND porc = par_porc AND vigencia = 'V';
        RETURN 0;
    ELSE
        RAISE EXCEPTION 'Operación no soportada';
    END IF;
END;
$$ LANGUAGE plpgsql;