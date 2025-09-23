-- Stored Procedure: sp_catalogo_deptos_por_dependencia
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de departamentos para una dependencia.
-- Generado para formulario: consultausuariosfrm
-- Fecha: 2025-08-26 15:58:09

CREATE OR REPLACE FUNCTION sp_catalogo_deptos_por_dependencia(p_id_dependencia INTEGER)
RETURNS TABLE (
    cvedepto INTEGER,
    nombredepto VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvedepto, nombredepto FROM deptos WHERE cvedependencia = p_id_dependencia ORDER BY nombredepto;
END;
$$ LANGUAGE plpgsql;