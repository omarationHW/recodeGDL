-- Stored Procedure: catalogo_actividades_update
-- Tipo: CRUD
-- Descripción: Actualiza una actividad existente
-- Generado para formulario: CatalogoActividadesFrm
-- Fecha: 2025-08-27 16:45:56

CREATE OR REPLACE FUNCTION catalogo_actividades_update(
  id INTEGER,
  id_giro INTEGER,
  descripcion TEXT,
  observaciones TEXT,
  vigente CHAR(1),
  usuario_mod VARCHAR(50)
) RETURNS TABLE (id_actividad INTEGER) AS $$
BEGIN
  UPDATE c_actividades_lic
  SET id_giro = id_giro,
      descripcion = descripcion,
      observaciones = observaciones,
      vigente = vigente,
      fecha_alta = CASE WHEN vigente = 'V' THEN NOW() ELSE fecha_alta END,
      usuario_alta = CASE WHEN vigente = 'V' THEN usuario_mod ELSE usuario_alta END,
      fecha_baja = CASE WHEN vigente = 'C' THEN NOW() ELSE NULL END,
      usuario_baja = CASE WHEN vigente = 'C' THEN usuario_mod ELSE NULL END
  WHERE id_actividad = id;
  RETURN QUERY SELECT id;
END;
$$ LANGUAGE plpgsql;