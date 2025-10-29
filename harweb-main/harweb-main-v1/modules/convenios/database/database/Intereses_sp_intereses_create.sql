-- Stored Procedure: sp_intereses_create
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de interés.
-- Generado para formulario: Intereses
-- Fecha: 2025-08-27 14:47:29

CREATE OR REPLACE FUNCTION sp_intereses_create(
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
    INSERT INTO ta_12_intereses(axo, mes, porcentaje, id_usuario, fecha_actual)
    VALUES (p_axo, p_mes, p_porcentaje, p_id_usuario, NOW());
    RETURN QUERY SELECT axo, mes, porcentaje, id_usuario, fecha_actual
      FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes;
END;
$$ LANGUAGE plpgsql;