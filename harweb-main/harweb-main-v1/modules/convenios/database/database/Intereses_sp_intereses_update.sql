-- Stored Procedure: sp_intereses_update
-- Tipo: CRUD
-- Descripción: Actualiza el porcentaje de un registro de interés existente.
-- Generado para formulario: Intereses
-- Fecha: 2025-08-27 14:47:29

CREATE OR REPLACE FUNCTION sp_intereses_update(
    p_axo smallint,
    p_mes smallint,
    p_porcentaje numeric(12,8),
    p_id_usuario integer
) RETURNS TABLE (
    axo smallint,
    mes smallint,
    porcentaje numeric(12,8),
    id_usuario integer,
    fecha_actual timestamp
) AS $$
BEGIN
    UPDATE ta_12_intereses
    SET porcentaje = p_porcentaje,
        id_usuario = p_id_usuario,
        fecha_actual = NOW()
    WHERE axo = p_axo AND mes = p_mes;
    RETURN QUERY SELECT axo, mes, porcentaje, id_usuario, fecha_actual
      FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes;
END;
$$ LANGUAGE plpgsql;