-- Stored Procedure: sp_buscar_forma
-- Tipo: Catalog
-- Descripción: Busca formas por folio
-- Generado para formulario: dderechosLic
-- Fecha: 2025-08-26 23:58:23

CREATE OR REPLACE FUNCTION sp_buscar_forma(p_folio INTEGER)
RETURNS TABLE(id_licencia INTEGER, licencia INTEGER, min INTEGER, max INTEGER, propietario TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT l.id_licencia, l.licencia,
      (SELECT MIN(d.axo) FROM detsal_lic d WHERE d.id_licencia=l.id_licencia AND d.forma>0 AND d.cvepago=0) AS min,
      (SELECT MAX(d.axo) FROM detsal_lic d WHERE d.id_licencia=l.id_licencia AND d.forma>0 AND d.cvepago=0 AND d.axo<=EXTRACT(YEAR FROM CURRENT_DATE)) AS max,
      l.propietario
    FROM licencias l
    JOIN saldos_lic s ON l.id_licencia=s.id_licencia
    WHERE l.licencia=p_folio AND s.formas>0 AND l.vigente='V' AND l.bloqueado=0;
END;
$$ LANGUAGE plpgsql;