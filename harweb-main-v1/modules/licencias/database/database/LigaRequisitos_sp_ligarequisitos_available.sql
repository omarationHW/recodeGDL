-- Stored Procedure: sp_ligarequisitos_available
-- Tipo: Report
-- Descripción: Lista los requisitos disponibles (no asignados) para un giro.
-- Generado para formulario: LigaRequisitos
-- Fecha: 2025-08-26 17:13:30

CREATE OR REPLACE FUNCTION sp_ligarequisitos_available(p_id_giro INT)
RETURNS TABLE(req INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT c.req, c.descripcion FROM c_girosreq c WHERE c.req NOT IN (SELECT req FROM giro_req WHERE id_giro = p_id_giro) ORDER BY c.req;
END;
$$ LANGUAGE plpgsql;