-- Stored Procedure: sp_interesesmtto_update
-- Tipo: CRUD
-- Descripción: Actualiza el porcentaje de interés de mantenimiento para un año y mes.
-- Generado para formulario: InteresesMtto
-- Fecha: 2025-08-27 14:49:07

CREATE OR REPLACE FUNCTION sp_interesesmtto_update(p_axo integer, p_mes integer, p_porc numeric, p_id_usuario integer)
RETURNS TABLE(result text) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes) THEN
        RETURN QUERY SELECT 'No existe el registro para ese año y mes'::text;
        RETURN;
    END IF;
    UPDATE ta_12_intereses
    SET porcentaje = p_porc,
        id_usuario = p_id_usuario,
        fecha_actual = NOW()
    WHERE axo = p_axo AND mes = p_mes;
    RETURN QUERY SELECT 'OK'::text;
END;
$$ LANGUAGE plpgsql;