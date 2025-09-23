-- Stored Procedure: sp_repdoc_get_requisitos
-- Tipo: Catalog
-- Descripción: Obtiene los requisitos documentales para un giro
-- Generado para formulario: repdoc
-- Fecha: 2025-08-26 17:50:37

CREATE OR REPLACE FUNCTION sp_repdoc_get_requisitos(p_id_giro INTEGER)
RETURNS TABLE(id_giro INTEGER, req INTEGER, descripcion TEXT, requisitos TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT r.id_giro, r.req, c.descripcion, c.requisitos
    FROM giro_req r
    JOIN c_girosreq c ON c.req = r.req
    WHERE r.id_giro = p_id_giro
    ORDER BY c.req;
END;
$$ LANGUAGE plpgsql;