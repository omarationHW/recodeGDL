-- Stored Procedure: sp_dscto_pp_create
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de descuento por pronto pago
-- Generado para formulario: Dscto_p_pago
-- Fecha: 2025-08-27 14:35:16

CREATE OR REPLACE PROCEDURE sp_dscto_pp_create(
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_porc_dscto NUMERIC,
    p_usuario_mov VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ta_16_dscto_pp (
        fecha_inicio, fecha_fin, porc_dscto, status, fecha_at, fecha_in, usuario_mov
    ) VALUES (
        p_fecha_inicio, p_fecha_fin, p_porc_dscto, 'V', CURRENT_DATE, CURRENT_DATE, p_usuario_mov
    );
END;
$$;