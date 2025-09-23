-- Stored Procedure: lic_grupos_get
-- Tipo: Catalog
-- Descripción: Obtiene un grupo de licencias por ID.
-- Generado para formulario: GruposLicenciasAbcfrm
-- Fecha: 2025-08-26 16:50:25

CREATE OR REPLACE FUNCTION lic_grupos_get(p_id INTEGER)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM lic_grupos
    WHERE id = p_id;
END;
$$;