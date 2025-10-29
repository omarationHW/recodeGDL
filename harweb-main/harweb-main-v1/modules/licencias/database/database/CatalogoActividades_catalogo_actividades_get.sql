-- Stored Procedure: catalogo_actividades_get
-- Tipo: Catalog
-- Descripción: Obtiene una actividad por ID
-- Generado para formulario: CatalogoActividadesFrm
-- Fecha: 2025-08-27 16:45:56

CREATE OR REPLACE FUNCTION catalogo_actividades_get(id INTEGER)
RETURNS TABLE (
  id_actividad INTEGER,
  id_giro INTEGER,
  descripcion TEXT,
  observaciones TEXT,
  vigente CHAR(1),
  fecha_alta TIMESTAMP,
  usuario_alta VARCHAR(50),
  fecha_baja TIMESTAMP,
  usuario_baja VARCHAR(50),
  motivo_baja TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT id_actividad, id_giro, descripcion, observaciones, vigente, fecha_alta, usuario_alta, fecha_baja, usuario_baja, motivo_baja
    FROM c_actividades_lic
    WHERE id_actividad = $1;
END;
$$ LANGUAGE plpgsql;