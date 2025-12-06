-- Stored Procedure: sp_fechadescuento_update
-- Tipo: CRUD
-- Descripción: Actualiza la fecha de descuento y recargos para un mes dado
-- Generado para formulario: FechaDescuento
-- Fecha: 2025-08-27 00:02:50

DROP FUNCTION IF EXISTS sp_fechadescuento_update(SMALLINT, DATE, DATE, INTEGER);

CREATE OR REPLACE FUNCTION sp_fechadescuento_update(
    p_mes SMALLINT,
    p_fecha_descuento DATE,
    p_fecha_recargos DATE,
    p_id_usuario INTEGER
) RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM publico.ta_11_fecha_desc fd WHERE fd.mes = p_mes;
    IF v_count = 0 THEN
        RETURN QUERY SELECT false::BOOLEAN, 'No existe el mes especificado'::TEXT;
        RETURN;
    END IF;
    UPDATE publico.ta_11_fecha_desc
    SET fecha_descuento = p_fecha_descuento,
        fecha_recargos = p_fecha_recargos,
        fecha_alta = NOW(),
        id_usuario = p_id_usuario
    WHERE mes = p_mes;
    RETURN QUERY SELECT true::BOOLEAN, 'Actualización exitosa'::TEXT;
END;
$$ LANGUAGE plpgsql;