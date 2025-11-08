-- Stored Procedure: get_tipo_bloqueo_catalog
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de tipos de bloqueo activos para selección.
-- Generado para formulario: tipobloqueofrm
-- Fecha: 2025-08-27 19:43:00

CREATE OR REPLACE FUNCTION get_tipo_bloqueo_catalog()
RETURNS TABLE(id integer, descripcion varchar, sel_cons char(1))
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT id, descripcion, sel_cons
    FROM c_tipobloqueo
    WHERE sel_cons = 'S';
END;
$$;