-- Stored Procedure: catalogo_giros_list
-- Tipo: Catalog
-- Descripción: Lista todos los giros vigentes para selección
-- Generado para formulario: CatalogoActividadesFrm
-- Fecha: 2025-08-27 16:45:56

CREATE OR REPLACE FUNCTION catalogo_giros_list()
RETURNS TABLE (
  id_giro INTEGER,
  descripcion TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT id_giro, descripcion FROM c_giros WHERE vigente = 'V' AND id_giro > 500 ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;