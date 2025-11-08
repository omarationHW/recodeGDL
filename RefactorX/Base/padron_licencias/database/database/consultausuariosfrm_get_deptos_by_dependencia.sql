-- Stored Procedure: get_deptos_by_dependencia
-- Tipo: Catalog
-- Descripción: Devuelve los departamentos de una dependencia específica.
-- Generado para formulario: consultausuariosfrm
-- Fecha: 2025-08-27 17:29:11

CREATE OR REPLACE FUNCTION get_deptos_by_dependencia(p_id_dependencia integer)
RETURNS TABLE (
    cvedepto integer,
    nombredepto varchar,
    telefono varchar,
    cvedependencia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvedepto, nombredepto, telefono, cvedependencia
    FROM deptos
    WHERE cvedependencia = p_id_dependencia
    ORDER BY nombredepto;
END;
$$ LANGUAGE plpgsql;