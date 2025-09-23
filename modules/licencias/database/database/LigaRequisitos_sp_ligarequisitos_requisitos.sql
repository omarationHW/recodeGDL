-- Stored Procedure: sp_ligarequisitos_requisitos
-- Tipo: Catalog
-- Descripción: Obtiene todos los requisitos posibles.
-- Generado para formulario: LigaRequisitos
-- Fecha: 2025-08-26 17:13:30

CREATE OR REPLACE FUNCTION sp_ligarequisitos_requisitos()
RETURNS TABLE(req INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT req, descripcion FROM c_girosreq ORDER BY req;
END;
$$ LANGUAGE plpgsql;