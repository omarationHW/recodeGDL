-- Stored Procedure: sp_fechadescuento_update
-- Tipo: CRUD
-- Descripción: Actualiza la fecha de descuento y recargos para un mes dado
-- Generado para formulario: FechaDescuento
-- Fecha: 2025-08-27 00:02:50

CREATE OR REPLACE FUNCTION sp_fechadescuento_update(
    p_mes smallint,
    p_fecha_descuento date,
    p_fecha_recargos date,
    p_id_usuario integer
) RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_count integer;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta_11_fecha_desc WHERE mes = p_mes;
    IF v_count = 0 THEN
        RETURN QUERY SELECT false, 'No existe el mes especificado';
        RETURN;
    END IF;
    UPDATE ta_11_fecha_desc
    SET fecha_descuento = p_fecha_descuento,
        fecha_recargos = p_fecha_recargos,
        fecha_alta = NOW(),
        id_usuario = p_id_usuario
    WHERE mes = p_mes;
    RETURN QUERY SELECT true, 'Actualización exitosa';
END;
$$ LANGUAGE plpgsql;