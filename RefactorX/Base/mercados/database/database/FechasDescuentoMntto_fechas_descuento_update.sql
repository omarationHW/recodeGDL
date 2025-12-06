-- Stored Procedure: fechas_descuento_update
-- Tipo: CRUD
-- Descripción: Actualiza la fecha de descuento y recargos para un mes.
-- Generado para formulario: FechasDescuentoMntto
-- Fecha: 2025-08-27 00:04:11
-- Desplegado: 2025-12-03 (corregido schema publico)

CREATE OR REPLACE FUNCTION fechas_descuento_update(
    p_mes smallint,
    p_fecha_descuento date,
    p_fecha_recargos date,
    p_id_usuario integer
) RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_mes_desc smallint;
    v_mes_rec smallint;
BEGIN
    v_mes_desc := EXTRACT(MONTH FROM p_fecha_descuento);
    v_mes_rec := EXTRACT(MONTH FROM p_fecha_recargos);

    IF v_mes_desc != p_mes OR v_mes_rec != p_mes THEN
        RETURN QUERY SELECT false, 'La fecha de descuento y recargos debe corresponder al mes seleccionado.';
        RETURN;
    END IF;

    UPDATE publico.ta_11_fecha_desc
    SET fecha_descuento = p_fecha_descuento,
        fecha_alta = NOW(),
        fecha_recargos = p_fecha_recargos,
        id_usuario = p_id_usuario
    WHERE mes = p_mes;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Actualización exitosa';
    ELSE
        RETURN QUERY SELECT false, 'No se encontró el mes a actualizar';
    END IF;
END;
$$ LANGUAGE plpgsql;