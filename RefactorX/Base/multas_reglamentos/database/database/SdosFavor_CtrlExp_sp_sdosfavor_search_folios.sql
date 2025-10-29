-- Stored Procedure: sp_sdosfavor_search_folios
-- Tipo: Report
-- Descripción: Obtiene la lista de folios de solic_sdosfavor filtrados por status.
-- Generado para formulario: SdosFavor_CtrlExp
-- Fecha: 2025-08-27 15:38:42

CREATE OR REPLACE FUNCTION sp_sdosfavor_search_folios(p_status TEXT DEFAULT NULL)
RETURNS TABLE(folio INTEGER, axofol INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT folio, axofol
    FROM solic_sdosfavor
    WHERE (p_status IS NULL OR p_status = '' OR status = p_status)
    ORDER BY folio ASC;
END;
$$ LANGUAGE plpgsql;