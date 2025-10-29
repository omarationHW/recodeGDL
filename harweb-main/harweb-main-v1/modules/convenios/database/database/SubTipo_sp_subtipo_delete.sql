-- Stored Procedure: sp_subtipo_delete
-- Tipo: CRUD
-- Descripción: Elimina un subtipo de convenio
-- Generado para formulario: SubTipo
-- Fecha: 2025-08-27 15:59:10

CREATE OR REPLACE FUNCTION sp_subtipo_delete(
    p_tipo smallint,
    p_subtipo smallint
) RETURNS TABLE (
    tipo smallint,
    subtipo smallint
) AS $$
BEGIN
    DELETE FROM ta_17_subtipo_conv WHERE tipo = p_tipo AND subtipo = p_subtipo;
    RETURN QUERY SELECT p_tipo, p_subtipo;
END;
$$ LANGUAGE plpgsql;