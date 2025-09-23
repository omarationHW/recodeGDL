-- Stored Procedure: sp_get_tramite_documents
-- Tipo: Report
-- Descripción: Obtiene los documentos asociados a un trámite.
-- Generado para formulario: carga_imagen
-- Fecha: 2025-08-26 15:09:29

CREATE OR REPLACE FUNCTION sp_get_tramite_documents(p_tramite_id integer)
RETURNS TABLE(
  id_imagen integer,
  cvedocto integer,
  feccap date,
  capturista text,
  documento text,
  id_tramite integer,
  id_licencia integer
) AS $$
BEGIN
  RETURN QUERY
    SELECT d.id_imagen, d.cvedocto, d.feccap, d.capturista, c.documento, d.id_tramite, d.id_licencia
    FROM digital_docs d
    INNER JOIN tramitedocs t ON t.id_imagen = d.id_imagen
    INNER JOIN c_doctos c ON c.id = d.cvedocto
    WHERE t.id_tramite = p_tramite_id
    ORDER BY d.feccap DESC;
END;
$$ LANGUAGE plpgsql;