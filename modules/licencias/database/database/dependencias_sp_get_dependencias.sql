-- Stored Procedure: sp_get_dependencias
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de dependencias activas para licencias
-- Generado para formulario: dependenciasFrm
-- Fecha: 2025-08-27 17:32:45

CREATE OR REPLACE FUNCTION sp_get_dependencias()
RETURNS TABLE(id_dependencia INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_dependencia, descripcion
    FROM c_dependencias
    WHERE licencias = 1 AND vigente = 'V'
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;