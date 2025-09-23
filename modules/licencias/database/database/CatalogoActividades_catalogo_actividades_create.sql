-- Stored Procedure: catalogo_actividades_create
-- Tipo: CRUD
-- Descripción: Crea una nueva actividad
-- Generado para formulario: CatalogoActividadesFrm
-- Fecha: 2025-08-27 16:45:56

CREATE OR REPLACE FUNCTION catalogo_actividades_create(
  id_giro INTEGER,
  descripcion TEXT,
  observaciones TEXT,
  vigente CHAR(1),
  usuario_alta VARCHAR(50)
) RETURNS TABLE (id_actividad INTEGER) AS $$
DECLARE
  new_id INTEGER;
BEGIN
  INSERT INTO c_actividades_lic (id_giro, descripcion, observaciones, vigente, fecha_alta, usuario_alta)
  VALUES (id_giro, descripcion, observaciones, vigente, NOW(), usuario_alta)
  RETURNING id_actividad INTO new_id;
  RETURN QUERY SELECT new_id;
END;
$$ LANGUAGE plpgsql;