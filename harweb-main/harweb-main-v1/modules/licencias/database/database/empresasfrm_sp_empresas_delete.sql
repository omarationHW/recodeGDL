-- Stored Procedure: sp_empresas_delete
-- Tipo: CRUD
-- Descripción: Elimina una empresa por su clave primaria.
-- Generado para formulario: empresasfrm
-- Fecha: 2025-08-26 16:14:20

CREATE OR REPLACE FUNCTION sp_empresas_delete(p_empresa INTEGER)
RETURNS TABLE (empresa INTEGER) AS $$
BEGIN
    DELETE FROM empresas WHERE empresa = p_empresa RETURNING empresa;
END;
$$ LANGUAGE plpgsql;