-- Stored Procedure: sp_interesesmtto_create
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de interés de mantenimiento. Si ya existe para el año y mes, retorna error.
-- Generado para formulario: InteresesMtto
-- Fecha: 2025-08-27 14:49:07

CREATE OR REPLACE FUNCTION sp_interesesmtto_create(p_axo integer, p_mes integer, p_porc numeric, p_id_usuario integer)
RETURNS TABLE(result text) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes) THEN
        RETURN QUERY SELECT 'Ya existe un registro para ese año y mes'::text;
        RETURN;
    END IF;
    INSERT INTO ta_12_intereses(axo, mes, porcentaje, id_usuario, fecha_actual)
    VALUES (p_axo, p_mes, p_porc, p_id_usuario, NOW());
    RETURN QUERY SELECT 'OK'::text;
END;
$$ LANGUAGE plpgsql;