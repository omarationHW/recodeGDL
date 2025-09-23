-- Stored Procedure: sp_update_aplicareq
-- Tipo: CRUD
-- Descripción: Actualiza la configuración de aplicación de requerimientos normales.
-- Generado para formulario: AplicaMultasNormal
-- Fecha: 2025-08-27 13:58:05

CREATE OR REPLACE FUNCTION sp_update_aplicareq(p_aplica CHAR(1), p_porc INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE ta_aplicareq SET aplica = p_aplica, porc = p_porc;
END;
$$ LANGUAGE plpgsql;