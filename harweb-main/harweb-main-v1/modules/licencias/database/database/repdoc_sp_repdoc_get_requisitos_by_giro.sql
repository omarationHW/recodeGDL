-- Stored Procedure: sp_repdoc_get_requisitos_by_giro
-- Tipo: Report
-- Descripción: Obtiene los requisitos documentales para un giro específico
-- Generado para formulario: repdoc
-- Fecha: 2025-08-27 19:18:22

CREATE OR REPLACE FUNCTION sp_repdoc_get_requisitos_by_giro(p_id_giro INTEGER)
RETURNS TABLE(req INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT r.req, gr.descripcion
    FROM giro_req r
    JOIN c_girosreq gr ON gr.req = r.req
    WHERE r.id_giro = p_id_giro
    ORDER BY gr.req;
END;
$$ LANGUAGE plpgsql;