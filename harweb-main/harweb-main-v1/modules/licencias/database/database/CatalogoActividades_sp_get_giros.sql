-- Stored Procedure: sp_get_giros
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de giros vigentes.
-- Generado para formulario: CatalogoActividadesFrm
-- Fecha: 2025-08-26 15:14:33

CREATE OR REPLACE FUNCTION sp_get_giros()
RETURNS TABLE (
    id_giro INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_giro, descripcion FROM c_giros WHERE id_giro > 500 AND vigente = 'V' ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;