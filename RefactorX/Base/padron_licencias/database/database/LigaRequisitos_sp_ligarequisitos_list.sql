-- Stored Procedure: sp_ligarequisitos_list
-- Tipo: Report
-- Descripción: Lista los requisitos asignados a un giro.
-- Generado para formulario: LigaRequisitos
-- Fecha: 2025-08-26 17:13:30

CREATE OR REPLACE FUNCTION sp_ligarequisitos_list(p_id_giro INT)
RETURNS TABLE(id_giro INT, req INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT r.id_giro, r.req, c.descripcion FROM giro_req r JOIN c_girosreq c ON c.req = r.req WHERE r.id_giro = p_id_giro ORDER BY c.req;
END;
$$ LANGUAGE plpgsql;