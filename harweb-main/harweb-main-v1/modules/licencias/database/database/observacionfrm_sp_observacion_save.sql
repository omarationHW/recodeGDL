-- Stored Procedure: sp_observacion_save
-- Tipo: CRUD
-- Descripción: Guarda una nueva observación en la tabla observaciones.
-- Generado para formulario: observacionfrm
-- Fecha: 2025-08-26 17:23:04

CREATE OR REPLACE FUNCTION sp_observacion_save(p_observacion TEXT)
RETURNS TABLE(id INTEGER, observacion TEXT, created_at TIMESTAMP) AS $$
DECLARE
  v_id INTEGER;
  v_now TIMESTAMP := NOW();
BEGIN
  INSERT INTO observaciones (observacion, created_at)
  VALUES (UPPER(p_observacion), v_now)
  RETURNING id, observacion, created_at INTO v_id, p_observacion, v_now;
  RETURN QUERY SELECT v_id, p_observacion, v_now;
END;
$$ LANGUAGE plpgsql;