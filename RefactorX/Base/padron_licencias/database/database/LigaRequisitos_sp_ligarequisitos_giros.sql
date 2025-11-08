-- Stored Procedure: sp_ligarequisitos_giros
-- Tipo: Catalog
-- Descripción: Obtiene todos los giros tipo L (licencia) para asignación de requisitos.
-- Generado para formulario: LigaRequisitos
-- Fecha: 2025-08-26 17:13:30

CREATE OR REPLACE FUNCTION sp_ligarequisitos_giros()
RETURNS TABLE(id_giro INT, descripcion TEXT, clasificacion TEXT, tipo TEXT, reglamentada TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_giro, descripcion, clasificacion, tipo, reglamentada FROM c_giros WHERE id_giro > 500 AND tipo = 'L' ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;