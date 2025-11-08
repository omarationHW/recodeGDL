-- Stored Procedure: catalogo_actividades_delete
-- Tipo: CRUD
-- Descripción: Marca una actividad como cancelada (baja lógica)
-- Generado para formulario: CatalogoActividadesFrm
-- Fecha: 2025-08-27 16:45:56

CREATE OR REPLACE FUNCTION catalogo_actividades_delete(
  id INTEGER,
  usuario_baja VARCHAR(50),
  motivo_baja TEXT
) RETURNS TABLE (id_actividad INTEGER) AS $$
BEGIN
  UPDATE c_actividades_lic
  SET vigente = 'C', fecha_baja = NOW(), usuario_baja = usuario_baja, motivo_baja = motivo_baja
  WHERE id_actividad = id;
  RETURN QUERY SELECT id;
END;
$$ LANGUAGE plpgsql;