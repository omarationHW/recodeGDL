-- Stored Procedure: sp_get_tramite_docs
-- Tipo: Report
-- Descripción: Obtiene los documentos asociados a un trámite
-- Generado para formulario: carga_imagen
-- Fecha: 2025-08-27 16:41:18

CREATE OR REPLACE FUNCTION sp_get_tramite_docs(p_tramite_id integer)
RETURNS TABLE(id_imagen integer, documento varchar, id_licencia integer) AS $$
BEGIN
  RETURN QUERY
    SELECT td.id_imagen, d.documento, td.id_licencia
    FROM tramitedocs td
    JOIN c_doctos d ON td.cvedocto = d.id
    WHERE td.id_tramite = p_tramite_id;
END;
$$ LANGUAGE plpgsql;