-- Stored Procedure: sp_busca_licencia
-- Tipo: Catalog
-- Descripción: Busca licencia por folio y tipo
-- Generado para formulario: drecgoLic
-- Fecha: 2025-08-27 00:52:37

CREATE OR REPLACE FUNCTION sp_busca_licencia(p_folio INTEGER, p_tipo VARCHAR) RETURNS TABLE(
  id_licencia INTEGER,
  licencia INTEGER,
  min SMALLINT,
  max SMALLINT,
  propietario VARCHAR
) AS $$
BEGIN
  RETURN QUERY
    SELECT l.id_licencia, l.licencia,
      (SELECT MIN(d.axo) FROM detsal_lic d WHERE d.id_licencia=l.id_licencia AND d.recargos>0 AND d.cvepago=0) AS min,
      (SELECT MAX(d.axo) FROM detsal_lic d WHERE d.id_licencia=l.id_licencia AND d.recargos>0 AND d.cvepago=0 AND d.axo<=EXTRACT(YEAR FROM CURRENT_DATE)) AS max,
      l.propietario
    FROM licencias l, saldos_lic s
    WHERE l.id_licencia=s.id_licencia AND l.licencia=p_folio AND (s.recargos>0 OR s.multas>0) AND l.vigente='V' AND l.bloqueado=0;
END;
$$ LANGUAGE plpgsql;