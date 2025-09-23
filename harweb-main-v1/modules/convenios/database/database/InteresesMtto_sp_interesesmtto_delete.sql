-- Stored Procedure: sp_interesesmtto_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de interés de mantenimiento por año y mes.
-- Generado para formulario: InteresesMtto
-- Fecha: 2025-08-27 14:49:07

CREATE OR REPLACE FUNCTION sp_interesesmtto_delete(p_axo integer, p_mes integer)
RETURNS TABLE(result text) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes) THEN
        RETURN QUERY SELECT 'No existe el registro para ese año y mes'::text;
        RETURN;
    END IF;
    DELETE FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes;
    RETURN QUERY SELECT 'OK'::text;
END;
$$ LANGUAGE plpgsql;