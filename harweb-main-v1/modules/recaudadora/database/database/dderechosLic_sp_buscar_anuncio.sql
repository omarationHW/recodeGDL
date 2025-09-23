-- Stored Procedure: sp_buscar_anuncio
-- Tipo: Catalog
-- Descripción: Busca anuncio por folio y retorna datos principales
-- Generado para formulario: dderechosLic
-- Fecha: 2025-08-26 23:58:23

CREATE OR REPLACE FUNCTION sp_buscar_anuncio(p_folio INTEGER)
RETURNS TABLE(id_anuncio INTEGER, anuncio INTEGER, min INTEGER, max INTEGER, propietario TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT l.id_anuncio, l.anuncio,
      (SELECT MIN(d.axo) FROM detsal_lic d WHERE d.id_anuncio=l.id_anuncio AND d.derechos>0 AND d.cvepago=0) AS min,
      (SELECT MAX(d.axo) FROM detsal_lic d WHERE d.id_anuncio=l.id_anuncio AND d.derechos>0 AND d.cvepago=0 AND d.axo<=EXTRACT(YEAR FROM CURRENT_DATE)) AS max,
      (SELECT propietario FROM licencias WHERE id_licencia=l.id_licencia) AS propietario
    FROM anuncios l
    JOIN saldos_lic s ON l.id_licencia=s.id_licencia
    WHERE l.anuncio=p_folio AND s.anuncios>0 AND l.vigente='V' AND (l.bloqueado IS NULL OR l.bloqueado=0);
END;
$$ LANGUAGE plpgsql;