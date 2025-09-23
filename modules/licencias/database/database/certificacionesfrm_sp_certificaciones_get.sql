-- Stored Procedure: sp_certificaciones_get
-- Tipo: Catalog
-- Descripción: Obtiene una certificación por ID
-- Generado para formulario: certificacionesfrm
-- Fecha: 2025-08-26 15:29:35

CREATE OR REPLACE FUNCTION sp_certificaciones_get(p_id INT)
RETURNS TABLE(id INT, axo INT, folio INT, id_licencia INT, partidapago TEXT, observacion TEXT, vigente TEXT, feccap DATE, capturista TEXT, tipo TEXT, licencia INT, anuncio INT) AS $$
BEGIN
  RETURN QUERY SELECT *, licencia, anuncio FROM certificaciones WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;