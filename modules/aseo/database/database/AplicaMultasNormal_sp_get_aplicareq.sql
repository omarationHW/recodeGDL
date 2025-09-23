-- Stored Procedure: sp_get_aplicareq
-- Tipo: Catalog
-- Descripción: Obtiene la configuración actual de aplicación de requerimientos normales.
-- Generado para formulario: AplicaMultasNormal
-- Fecha: 2025-08-27 13:58:05

CREATE OR REPLACE FUNCTION sp_get_aplicareq()
RETURNS TABLE(descripcion TEXT, aplica CHAR(1), porc INTEGER) AS $$
BEGIN
  RETURN QUERY SELECT descripcion, aplica, porc FROM ta_aplicareq LIMIT 1;
END;
$$ LANGUAGE plpgsql;