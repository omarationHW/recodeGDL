-- Stored Procedure: sp_dscto_pp_delete
-- Tipo: CRUD
-- Descripción: Cancela (baja lógica) un registro de descuento por pronto pago
-- Generado para formulario: Dscto_p_pago
-- Fecha: 2025-08-27 14:35:16

CREATE OR REPLACE PROCEDURE sp_dscto_pp_delete(
    p_id INTEGER,
    p_usuario_mov VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ta_16_dscto_pp
    SET status = 'C', fecha_in = CURRENT_DATE, usuario_mov = p_usuario_mov
    WHERE id = p_id AND status = 'V';
END;
$$;