-- Stored Procedure: sp_busca_anuncio
-- Tipo: Catalog
-- Descripción: Busca anuncio por folio y tipo
-- Generado para formulario: drecgoLic
-- Fecha: 2025-08-27 00:52:37

CREATE OR REPLACE FUNCTION sp_busca_anuncio(p_folio INTEGER, p_tipo VARCHAR) RETURNS TABLE(
  id_anuncio INTEGER,
  anuncio INTEGER,
  propietario VARCHAR,
  min SMALLINT,
  max SMALLINT
) AS $$
BEGIN
  RETURN QUERY
    SELECT l.id_anuncio, l.anuncio,
      (SELECT propietario FROM licencias WHERE id_licencia=l.id_licencia) AS propietario,
      (SELECT MIN(d.axo) FROM detsal_lic d WHERE d.id_anuncio=l.id_anuncio AND d.recargos>0 AND d.cvepago=0) AS min,
      (SELECT MAX(d.axo) FROM detsal_lic d WHERE d.id_anuncio=l.id_anuncio AND d.recargos>0 AND d.cvepago=0 AND d.axo<=EXTRACT(YEAR FROM CURRENT_DATE)) AS max
    FROM anuncios l, saldos_lic s
    WHERE l.id_licencia=s.id_licencia AND l.anuncio=p_folio AND s.recargos>0 AND l.vigente='V' AND (l.bloqueado IS NULL OR l.bloqueado=0);
END;
$$ LANGUAGE plpgsql;