-- Stored Procedure: sp_certificaciones_search
-- Tipo: Report
-- Descripción: Búsqueda avanzada de certificaciones
-- Generado para formulario: certificacionesfrm
-- Fecha: 2025-08-27 17:08:49

CREATE OR REPLACE FUNCTION sp_certificaciones_search(
  p_axo INT DEFAULT NULL, p_folio INT DEFAULT NULL, p_id_licencia INT DEFAULT NULL, p_feccap_ini DATE DEFAULT NULL, p_feccap_fin DATE DEFAULT NULL, p_tipo TEXT DEFAULT NULL
) RETURNS TABLE(id INT, axo INT, folio INT, id_licencia INT, partidapago TEXT, observacion TEXT, vigente TEXT, feccap DATE, capturista TEXT, tipo TEXT) AS $$
BEGIN
  RETURN QUERY SELECT * FROM certificaciones
    WHERE (p_axo IS NULL OR axo = p_axo)
      AND (p_folio IS NULL OR folio = p_folio)
      AND (p_id_licencia IS NULL OR id_licencia = p_id_licencia)
      AND (p_feccap_ini IS NULL OR feccap >= p_feccap_ini)
      AND (p_feccap_fin IS NULL OR feccap <= p_feccap_fin)
      AND (p_tipo IS NULL OR tipo = p_tipo)
    ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;